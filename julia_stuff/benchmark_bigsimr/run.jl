using Bigsimr, Distributions
using DataFrames
using BenchmarkTools

# "preheat" the bigsimr functions
cor(rand(10), rand(10), Pearson)
cor(rand(10), rand(10), Spearman)
cor(rand(10), rand(10), Kendall)

cor(rand(10, 10), Pearson)
cor(rand(10, 10), Spearman)
cor(rand(10, 10), Kendall)

cor_fast(rand(10, 10), Pearson)
cor_fast(rand(10, 10), Spearman)
cor_fast(rand(10, 10), Kendall)

cor_convert(rand(10, 10), Spearman, Pearson)
cor_convert(rand(10, 10), Kendall, Pearson)

d = NegativeBinomial(20, 0.2)
pearson_match(0.5, d, d)

d = NegativeBinomial(20, 0.002)
pearson_bounds(d, d)
pearson_match(0.5, d, d)

d = Gamma(2, 0.002)
pearson_bounds(d, d)
pearson_match(0.5, d, d)

s = cor_randPSD(100)
p = cor_convert(s, Spearman, Pearson)
r = cor_nearPD(p)
cor_nearPD(p, 1e-6)
cor_nearPD(p, 1e-6, tol=1e-6)
cor_fastPD(p)

k = cor_randPSD(1000)
p = cor_convert(s, Kendall, Pearson)
Bigsimr.iscorrelation(p)
@btime cor_nearPD(p, 1e-6, tol=1e-2)
@btime cor_nearPD(p, 1e-6, tol=1e-6)
@btime cor_fastPD(p)

r1 = cor_nearPD(p, 1e-6, tol=1e-2)
r2 = cor_nearPD(p, 1e-6, tol=1e-6)
r3 = cor_fastPD(p)

Bigsimr.iscorrelation(r1)
Bigsimr.iscorrelation(r2)
Bigsimr.iscorrelation(r3)

d = Gamma(3, 0.01)
rvec(10, cor_randPD(2), [d, d])

d = 20
tmp_cor = cor_randPD(d)
shapes = rand(Uniform(1, 10), d)
rates  = rand(Exponential(1/5), d)
tmp_margins = [Gamma(s, r) for (s,r) in zip(shapes, rates)]
pearson_match(tmp_cor, tmp_margins)

# make synthetic data
d = 10_000
shapes = rand(Uniform(1, 10), d)
rates  = rand(Exponential(1/5), d)
corr   = cor_randPSD(d)

