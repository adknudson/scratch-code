### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 875d267e-7d0c-11eb-3ed6-c3798cc4485a
using Bigsimr, GeneralizedSDistributions, Distributions

# ╔═╡ fc0dbcfa-7d15-11eb-0759-f16f1ffd7b64
using StatsPlots

# ╔═╡ d856d872-7d0c-11eb-2d65-ef4f368b2e71
md"""
# Capabilities and Limitations of GS-Distributions
"""

# ╔═╡ 7d5f7da6-7d0d-11eb-307c-bfa07849a023
md"""
## Simple Use Case
"""

# ╔═╡ 1970967e-7d12-11eb-1d3d-6f6013423b80
D1 = Gamma(2, 2)

# ╔═╡ 20706d58-7d12-11eb-3fd5-6fa7b81931cd
G1 = GSDist(D1)

# ╔═╡ 126c505a-7d17-11eb-38ac-3bb0328c741f
md"""
### Comparing statistical measures
"""

# ╔═╡ 2f523058-7d13-11eb-2e3e-89cf4a658c4b
map(mean, (D1, G1))

# ╔═╡ b4f3e772-7d15-11eb-2c00-79a3cc89325e
map(median, (D1, G1))

# ╔═╡ e819a6ca-7d13-11eb-3050-333ae0f1e38d
map(mode, (D1, G1))

# ╔═╡ c5e177e0-7d13-11eb-0ca0-1d82d172c985
map(var, (D1, G1))

# ╔═╡ bcb24b84-7d15-11eb-2c2c-0b815088fe57
# map(std, (D1, G1))

# ╔═╡ 0b36f5aa-7d13-11eb-32fa-7135d87779b0
map(m->cdf(m, 3), (D1, G1))

# ╔═╡ e2f39fa2-7d13-11eb-0473-37cab0d7a6f9
map(m->quantile(m, 0.88), (D1, G1))

# ╔═╡ 86704d56-7d14-11eb-1d81-49caba162a52
map(m->pdf(m, π), (D1, G1))

# ╔═╡ 9147cae2-7d14-11eb-16d5-7d5614a05283
map(m->logpdf(m, 2π), (D1, G1))

# ╔═╡ 228a7eda-7d17-11eb-2591-55f8137dd4bb
md"""### Comparing Distributions"""

# ╔═╡ 38a32470-7d16-11eb-2ce3-9d929e91e405
begin
	plot(D1, func=pdf, legend=:topright, label="Gamma", title="PDF")
	plot!(G1, func=pdf, xlims=(0, 30), label="GSDist")
end

# ╔═╡ 8ff50d7e-7d16-11eb-0424-b332d4dab381
begin
	plot(D1, func=cdf, legend=:bottomright, label="Gamma", title="CDF")
	plot!(G1, func=cdf, xlims=(0, 30), label="GSDist")
end

# ╔═╡ ddb44354-7d16-11eb-135c-a5ac19f99dd3
begin
	plot(D1, func=quantile, legend=:topleft, label="Gamma", title="Quantile")
	plot!(G1, func=quantile, xlims=(0, 1), label="GSDist")
end

# ╔═╡ 21665e1e-7d16-11eb-3671-ffa77e6bbcae
md"""
## Lmitations
"""

# ╔═╡ Cell order:
# ╟─d856d872-7d0c-11eb-2d65-ef4f368b2e71
# ╠═875d267e-7d0c-11eb-3ed6-c3798cc4485a
# ╠═fc0dbcfa-7d15-11eb-0759-f16f1ffd7b64
# ╟─7d5f7da6-7d0d-11eb-307c-bfa07849a023
# ╠═1970967e-7d12-11eb-1d3d-6f6013423b80
# ╠═20706d58-7d12-11eb-3fd5-6fa7b81931cd
# ╟─126c505a-7d17-11eb-38ac-3bb0328c741f
# ╠═2f523058-7d13-11eb-2e3e-89cf4a658c4b
# ╠═b4f3e772-7d15-11eb-2c00-79a3cc89325e
# ╠═e819a6ca-7d13-11eb-3050-333ae0f1e38d
# ╠═c5e177e0-7d13-11eb-0ca0-1d82d172c985
# ╠═bcb24b84-7d15-11eb-2c2c-0b815088fe57
# ╠═0b36f5aa-7d13-11eb-32fa-7135d87779b0
# ╠═e2f39fa2-7d13-11eb-0473-37cab0d7a6f9
# ╠═86704d56-7d14-11eb-1d81-49caba162a52
# ╠═9147cae2-7d14-11eb-16d5-7d5614a05283
# ╟─228a7eda-7d17-11eb-2591-55f8137dd4bb
# ╟─38a32470-7d16-11eb-2ce3-9d929e91e405
# ╟─8ff50d7e-7d16-11eb-0424-b332d4dab381
# ╟─ddb44354-7d16-11eb-135c-a5ac19f99dd3
# ╟─21665e1e-7d16-11eb-3671-ffa77e6bbcae
