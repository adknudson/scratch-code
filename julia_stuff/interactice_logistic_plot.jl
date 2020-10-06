### A Pluto.jl notebook ###
# v0.11.14

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

# ╔═╡ 7c1f8b60-d77d-11ea-21b3-d15aa0e50659
using Distributions, StatsPlots, PlutoUI

# ╔═╡ bdfbe494-0299-11eb-0dfe-3b0bb5f19d50


# ╔═╡ 84afba84-d77d-11ea-20cf-abd102229eff
function random_coef(n::Int, dA, dB)
	return rand(dA, n), rand(dB, n)
end

# ╔═╡ 138d0d74-d77e-11ea-3a3a-7f9776a93f32
F(x, a, b) = 1 / (1 + exp(-(b * (x - a))))

# ╔═╡ fee5136c-fc58-11ea-3796-35567ac94d11
F2(x, a, b) = F(x, a, exp(b))

# ╔═╡ 2f14442e-d77e-11ea-1c2c-6f8928693a7f
function sample_F(n, size, xs, F, a, b)
	N = n * length(xs)
	X = repeat(xs, inner=n)
	Y = Vector{Float64}(undef, N)
	for (i, x) in enumerate(xs)
		s = rand(Binomial(size, F(x, a, b)), n) ./ size
		Y[i*n-n+1:i*n] .= s
	end
	return X, Y
end

# ╔═╡ 1d7932a0-d782-11ea-30ab-bbd898f7d004
begin
	a_slider = @bind a html"<input type='range' min='-0.1' max='0.1' step='0.01' value='0.0'>"
	b_slider = @bind b html"<input type='range' min='0' max='50.0' value='5'>"
	
	md"""
	a: -0.1 $(a_slider) 0.1

	b: 0.0 $(b_slider) 50
	"""
end

# ╔═╡ f73251d2-d77f-11ea-1f13-bd96ccbe7a05
begin
	xn = quantile.(Beta(3, 3), 0:0.01:1) .- 0.5
	xs = -0.5:0.05:0.5
	x, y = sample_F(10, 3, xs, F, a, b)
	scatter(x, y, alpha = 0.2, legend=false, xlim=(-0.55, 0.55))
	plot!(xn, F.(xn, a, b))
end

# ╔═╡ aa44a628-d792-11ea-31e5-9da1d1747838
@show (a = a, b = b)

# ╔═╡ acd14d66-d782-11ea-14a0-9707de057ba6
function plot_F_family(n, dA, dB, F)
	xn = quantile.(Beta(2, 2), 0:0.01:1) .- 0.5
	αs, βs = random_coef(n, dA, dB)
	p = plot(bg=:white, xlim=(-0.5, 0.5), ylim=(0, 1))
	for i in 1:n
		plot!(xn, F.(xn, αs[i], βs[i]), alpha = 0.3, color=:steelblue4, legend=false)
	end
	return p
end

# ╔═╡ f0bd4ec8-d785-11ea-2f51-c3a1d71865a2
md"""
| $\mu_\alpha$ | $(@bind μa Slider(-0.1:0.01:0.1, default=0.0, show_value=true)) |

| $\sigma_\alpha$ | $(@bind σa Slider(0.005:0.005:0.5, default=0.1, show_value=true)) |

| $\mu_\beta$ | $(@bind μb Slider(-5:0.1:5, default=2.0, show_value=true)) |

| $\sigma_\beta$ | $(@bind σb Slider(0.1:0.1:2.0, default=1.0, show_value=true))|

| $n$ | $(@bind n Slider(1:500, default=100, show_value=true)) |
"""

# ╔═╡ fe9959f8-d783-11ea-1385-894e7dfdc2ca
plot_F_family(n, Normal(μa, σa), (Normal(μb, σb)), F2)

# ╔═╡ b195636c-d784-11ea-3930-45f507d01339
@show (μa = μa, σa = σa, μb = μb, σb = σb)

# ╔═╡ Cell order:
# ╠═7c1f8b60-d77d-11ea-21b3-d15aa0e50659
# ╠═bdfbe494-0299-11eb-0dfe-3b0bb5f19d50
# ╠═84afba84-d77d-11ea-20cf-abd102229eff
# ╠═138d0d74-d77e-11ea-3a3a-7f9776a93f32
# ╠═fee5136c-fc58-11ea-3796-35567ac94d11
# ╠═2f14442e-d77e-11ea-1c2c-6f8928693a7f
# ╟─1d7932a0-d782-11ea-30ab-bbd898f7d004
# ╠═f73251d2-d77f-11ea-1f13-bd96ccbe7a05
# ╟─aa44a628-d792-11ea-31e5-9da1d1747838
# ╠═acd14d66-d782-11ea-14a0-9707de057ba6
# ╟─f0bd4ec8-d785-11ea-2f51-c3a1d71865a2
# ╠═fe9959f8-d783-11ea-1385-894e7dfdc2ca
# ╟─b195636c-d784-11ea-3930-45f507d01339
