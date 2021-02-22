### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 40729092-5443-11eb-1c84-a56c0899ad65
begin
	using MvSim, Distributions
	using PlutoUI, Polynomials, Plots
	using Printf
	plotly()
end

# ╔═╡ 8918c910-5443-11eb-2f95-290e6ee0204a
begin
	dA = Binomial(2, 0.2)
	dB = Binomial(2, 0.2)
end;

# ╔═╡ ffbc153c-5447-11eb-3196-cf3a3b677267
pearson_bounds(dA, dB)

# ╔═╡ d3b666da-5443-11eb-38f7-331e5517f72e
md"""
n $(@bind n Slider(1:2:19, default=9, show_value=true))

ρ $(@bind ρ Slider(-1:0.05:1, default=0.0, show_value=true))
"""

# ╔═╡ a61b2236-5443-11eb-24dd-e3ae25b560e8
begin
	σA = std(dA)
    σB = std(dB)
    minA = minimum(dA)
    minB = minimum(dB)
    maxA = maximum(dA)
    maxB = maximum(dB)

    maxA = isinf(maxA) ? quantile(dA, 0.99) : maxA
    maxB = isinf(maxB) ? quantile(dB, 0.99) : maxB

    # Support sets
    A = minA:maxA
    B = minB:maxB

    # z = Φ⁻¹[F(A)], α[0] = -Inf, β[0] = -Inf
    # α = [-Inf; MvSim._norminvcdf.(cdf.(dA, A))]
	α = [-Inf; quantile.(Normal(), cdf.(dA, A))]
    # β = [-Inf; MvSim._norminvcdf.(cdf.(dB, B))]
	β = [-Inf; quantile.(Normal(), cdf.(dB, B))]

    c2 = 1 / (σA * σB)

    coef = zeros(Float64, n+1)
    for k in 1:n
        coef[k+1] = MvSim.Gn0d(k, A, B, α, β, c2) / factorial(k)
    end
    coef[1] = -ρ
	P = Polynomial(coef)
	rt = MvSim.solve_poly_pm_one(coef)
end

# ╔═╡ 2653aa6a-5444-11eb-36e5-a3531703ae82
begin
	lbl = @sprintf("%0.3f", rt)
	plot(P, xlims=(-1.1, 1.1), lagend=false)
	scatter!(
		[rt], [0], 
		legend = false,
		annotations = (rt, -0.05, Plots.text(lbl, :left))
	)
end

# ╔═╡ Cell order:
# ╠═40729092-5443-11eb-1c84-a56c0899ad65
# ╠═8918c910-5443-11eb-2f95-290e6ee0204a
# ╠═ffbc153c-5447-11eb-3196-cf3a3b677267
# ╠═a61b2236-5443-11eb-24dd-e3ae25b560e8
# ╠═d3b666da-5443-11eb-38f7-331e5517f72e
# ╠═2653aa6a-5444-11eb-36e5-a3531703ae82
