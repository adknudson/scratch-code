### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ ce79b460-57c7-11eb-3a94-097dce3ad747
using Distributions, StatsPlots

# ╔═╡ d4ce4574-57c7-11eb-0116-6de0e33654f3
n = 1_000

# ╔═╡ 5ddcc736-57c9-11eb-0a2b-b5ebfa072d6b
md"""**Observation**

Fitting a Gamma distribution only works when the support set is sufficiently large. For example, NB(4, 0.2) does not fit, but NB(4, 0.02) does.
"""

# ╔═╡ dc015ed0-57c7-11eb-396f-0d7bb384d90f
NB = NegativeBinomial(4, 0.000002)

# ╔═╡ e97768fc-57c7-11eb-2cc7-dfdc45105b05
x = rand(NB, n); x₀ = median(x); y = x / x₀;

# ╔═╡ f03056ec-57c7-11eb-3c71-dbc42e5fb778
histogram(x, bins=30, normalize=true, label="x")

# ╔═╡ f926ad94-57c7-11eb-0100-b1f445092473
histogram(y, bins=30, normalize=true, label="y")

# ╔═╡ ed86404e-57c7-11eb-2bee-9d6a639642fa
Gx = fit_mle(Gamma, x)

# ╔═╡ 49c5bc80-57c9-11eb-2199-5d707fd7f914
Gy = fit_mle(Gamma, y)

# ╔═╡ 8d00588e-57c9-11eb-39c5-31c0d418fc80
let q = 1-1e-15
	(
		NB = quantile(NB, q), 
		x  = quantile(x, q), 
		Gx = quantile(Gx, q), 
		Gy = quantile(Gy, q)*x₀
	)
end

# ╔═╡ Cell order:
# ╠═ce79b460-57c7-11eb-3a94-097dce3ad747
# ╠═d4ce4574-57c7-11eb-0116-6de0e33654f3
# ╟─5ddcc736-57c9-11eb-0a2b-b5ebfa072d6b
# ╠═dc015ed0-57c7-11eb-396f-0d7bb384d90f
# ╠═e97768fc-57c7-11eb-2cc7-dfdc45105b05
# ╟─f03056ec-57c7-11eb-3c71-dbc42e5fb778
# ╟─f926ad94-57c7-11eb-0100-b1f445092473
# ╠═ed86404e-57c7-11eb-2bee-9d6a639642fa
# ╠═49c5bc80-57c9-11eb-2199-5d707fd7f914
# ╠═8d00588e-57c9-11eb-39c5-31c0d418fc80
