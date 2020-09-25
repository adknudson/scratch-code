using DataFrames
using Distributions
using GLM
using Random

import GLM: Link, Link01, linkfun, linkinv, mueta, inverselink

Φ(x::Real)   = cdf(Normal(), x)
ϕ(x::Real)   = pdf(Normal(), x)
Φ⁻¹(x::Real) = quantile(Normal(), x)

struct Probit2AFCLink <: Link end
linkfun(::Probit2AFCLink, μ::Real) = Φ⁻¹(2*max(μ, nextfloat(0.5)) - 1)
linkinv(::Probit2AFCLink, η::Real) = (1 + Φ(η)) / 2
mueta(::Probit2AFCLink,   η::Real) = ϕ(η) / 2
function inverselink(::Probit2AFCLink, η::Real)
    μ = (1 + Φ(η)) / 2
    d = ϕ(η) / 2
    return μ, d, oftype(μ, NaN)
end

# Simple GLM ------------------------------------------------------------------
n_each_x = 20
x = repeat(0.04:0.04:0.32, n_each_x)
shuffle!(x)
N = length(x)

a, b = -4.5, 25
η = a .+ b .* x
μ = cdf.(Normal(), η)
y = rand.(Bernoulli.(μ))

df = DataFrame(y = y, x = x)
glm( @formula(y ~ x) , df, Binomial(), ProbitLink())

# 2-AFC Probit GLM-------------------------------------------------------------
μ = 0.5 .+ 0.5 * cdf.(Normal(), η)
y = rand.(Bernoulli.(μ))
df = DataFrame(y = y, x = x)
glm( @formula(y ~ x) , df, Binomial(), Probit2AFCLink())

