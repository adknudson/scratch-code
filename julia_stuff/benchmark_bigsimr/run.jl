using Bigsimr
using Distributions
using DataFrames
using BenchmarkTools
using Dates
using CSV

using Logging, LoggingExtras
logger = FileLogger("bench.log")
global_logger(logger)


Base.clamp(R::Matrix, L::Matrix, U::Matrix) = clamp.(R, L, U)


function my_bench(mat::Matrix, d::Int, C::Type{<:Bigsimr.Correlation}, n=10_000)
    @info "Beginning benchmark at $(DateTime(now())) with" Dimension=d Correlation=C Samples=n

    @info "Step 0 - Estimating parameters"
    m = mat[:,1:d]
    margins = [fit(Gamma, x) for x in eachcol(m)]

    @info "Step 1 - Estimating the correlation"
    s1 = @timed begin
        if C === Kendall
            cor_fast(m, Kendall)
        else
            cor(m, C)
        end
    end

    @info "Step 2 - Adjusting the correlation"
    s2 = @timed begin
        if C === Pearson
            pearson_match(s1.value, margins)
        else
            cor_convert(s1.value, C, Pearson)
        end
    end

    @info "Step 3 - Checking the correlation admissibility"
    s3 = @timed !Bigsimr.iscorrelation(s2.value) ? cor_nearPD(s2.value) : s2.value

    @info "Step 4 - Simulating the data"
    s4 = @timed rvec(n, s3.value, margins)

    @info "Ending benchmark at $(DateTime(now()))"
    DataFrame(
        dim = d,
        corr = C,
        samples = n,
        corr_time = s1.time,
        adjust_time = s2.time,
        admiss_time = s3.time,
        sim_time = s4.time,
        total_time = s1.time + s2.time + s3.time + s4.time
    )
end



@info "Creating synthetic data"
d = 5_000

@info "Generating Gamma parameters"
shapes = rand(Uniform(1, 10), d)
rates = rand(Exponential(1/5), d)
margins = [Gamma(s, r) for (s,r) in zip(shapes, rates)]

@info "Creating a valid correlation matrix"
lb, ub = pearson_bounds(margins)
corr = cor_randPSD(d)
corr = clamp(corr, lb, ub)
if !Bigsimr.iscorrelation(corr)
    corr = cor_nearPD(corr)
end

@info "Simulating correlated Gamma margins"
mat = rvec(10_000, corr, margins)

@info "Running the benchmarks"
cor_types = (Pearson, Spearman, Kendall)
dim_sizes = (2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000)
sample_sizes = (100, 1000, 10_000)
@info "Configuration:" cor_types dim_sizes sample_sizes


benchmark_results = vcat(
    [my_bench(mat, d, c, n) for d in dim_sizes, c in cor_types, n in sample_sizes]...
)

@info "Saving the results"
CSV.write("benchmark_results.csv", benchmark_results)