using Distributions, MvSim, BenchmarkTools

function make_margins(d::Int)
	sizes = rand(5:25, d)
	probs = rand(Uniform(0.3, 0.7), d)
	
	[NegativeBinomial(s, p) for (s, p) in zip(sizes, probs)]
end

n = 10000
d = 5000
ρ = cor_randPSD(d)
margins = make_margins(d)

MvSim._randn(Float32, 10, 10)
MvSim._rmvn(n, ρ)

@which rvec(n, ρ, margins)
x = rvec(n, ρ, margins)

@benchmark rvec(n, ρ, margins)

#= Old
#>BenchmarkTools.Trial: 
  memory estimate:  1.68 GiB
  allocs estimate:  20359
  --------------
  minimum time:     2.833 s (0.74% GC)
  median time:      2.868 s (0.61% GC)
  mean time:        2.868 s (0.61% GC)
  maximum time:     2.903 s (0.49% GC)
  --------------
  samples:          2
  evals/sample:     1
=#

#= New
#>BenchmarkTools.Trial: 
  memory estimate:  1.30 GiB
  allocs estimate:  20348
  --------------
  minimum time:     2.649 s (0.41% GC)
  median time:      2.656 s (0.20% GC)
  mean time:        2.656 s (0.20% GC)
  maximum time:     2.663 s (0.00% GC)
  --------------
  samples:          2
  evals/sample:     1
=#