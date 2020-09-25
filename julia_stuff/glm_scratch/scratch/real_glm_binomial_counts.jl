using DataFrames
using DataFramesMeta
using Distributions
using GLM
using CSV

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

df = DataFrame(CSV.File("data/motion_coherence_data.csv"))

@linq df |>
select([:stim1, :condition1, :correct]) |> 
groupby([:condition1, :stim1])


glm( @formula(correct ~ condition1) , df, Binomial(), Probit2AFCLink())
glm( @formula(correct ~ condition1) , df, Bernoulli(), Probit2AFCLink())
