### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ a8d2923a-577d-11eb-3367-ef0b03973886
using MvSim, Distributions, BenchmarkTools

# ╔═╡ 50c165f0-578f-11eb-20a0-ab5f12b1ca0a
# NOTE: Using MvSim commit: 4d83c6dd6567c98e9182118b417dfa8bd8739f2b

# ╔═╡ 7ea032d0-5783-11eb-2878-25f2d2dfbf73
md"""# Evaluating the GSDistribution

"""

# ╔═╡ 0e497f5c-5783-11eb-103c-e1c285e4731f
md"""## General Distribution Properties"""

# ╔═╡ be213dee-577d-11eb-378c-2dfc2c4d3866
D = NegativeBinomial(4, 0.02)

# ╔═╡ d0372e58-577d-11eb-0a08-f73e27affc49
G = GSDistribution(D)

# ╔═╡ 973b2f5e-5780-11eb-3a08-2fba1b06b620
# True distribution properties
mean(D), var(D), std(D)

# ╔═╡ dac793e4-577d-11eb-25d1-31830a2145c4
# Approximated distribution properties
mean(G), var(G), std(G)

# ╔═╡ 1d296b22-5783-11eb-26dd-8d707fa8aaaf
md"""## Pearson Bounds"""

# ╔═╡ 9ff2dda2-5780-11eb-3eb9-a9ac41ff617e
# True distribution bounds
pearson_bounds(D, D)

# ╔═╡ a840ad9a-5780-11eb-212b-3d40a6909569
# Approximated distribution bounds
pearson_bounds(G, G)

# ╔═╡ b08ed18e-5780-11eb-1a6d-93ccea6b4b5b
# True mapping value
pearson_match(-0.87, D, D)

# ╔═╡ d01ba77c-5780-11eb-31c7-edd964c2dd1b
# Approximated mapping value
pearson_match(-0.87, G, G)

# ╔═╡ d695d7a4-5782-11eb-3587-c92103d9d10d
md"""## Mapping Benchmark

### Converting to GSDistribution
"""

# ╔═╡ 343c022a-5783-11eb-1b61-11e3fe34a6b2
# Time to convert the discrete distribution
@benchmark GSDistribution(D)

# ╔═╡ 000f1b12-5784-11eb-3c69-473702025c78
md"""### Mapping"""

# ╔═╡ 47013696-5783-11eb-0a7e-05a6cee34e9f
# Time for discrete distribution
@benchmark pearson_match(-0.8, D, D)

# ╔═╡ 56a95004-5783-11eb-0ce8-cb5dc50488d8
# Time for continuous distribution (GSDist)
@benchmark pearson_match(-0.8, G, G)

# ╔═╡ 424491a6-5784-11eb-1f89-1dd15f770409
md"""## Conclusion

For discrete distributions with infinite support (e.g. NB), we can set a cutoff value such as the $99.999^{th}$ percentile, essentially treating it as a discrete distribution with finite support. Then there are two cases: discrete distributions with *small* finite support, and discrete distributions with large finite support.

A distribution has a small finite support if the cardinality of the support is less than about 1500. This rule of thumb is so that the worst case Pearson mapping step (input near the bounds) can still complete in less than a second. 

Even a second can still be infeasible when there are thousands of margins to process. A better hueristic is to choose a support size so that the Pearson mapping time for the discrete case is about the same as the time for the continuous. This leads to a support size of about 100, though there's not much of a practical difference for support size less than 200.

As a convenient side-effect, the GS-Distribution also better approximates discrete distributions with larger support. So not only is it faster, for larger finite support  distributions, but it also doesn't make sense for distributions with small finite support ($\Vert D \Vert <200$) which already are fast enough to use the exact discrete mapping.


"""

# ╔═╡ Cell order:
# ╠═50c165f0-578f-11eb-20a0-ab5f12b1ca0a
# ╟─7ea032d0-5783-11eb-2878-25f2d2dfbf73
# ╠═a8d2923a-577d-11eb-3367-ef0b03973886
# ╟─0e497f5c-5783-11eb-103c-e1c285e4731f
# ╠═be213dee-577d-11eb-378c-2dfc2c4d3866
# ╠═d0372e58-577d-11eb-0a08-f73e27affc49
# ╠═973b2f5e-5780-11eb-3a08-2fba1b06b620
# ╠═dac793e4-577d-11eb-25d1-31830a2145c4
# ╟─1d296b22-5783-11eb-26dd-8d707fa8aaaf
# ╠═9ff2dda2-5780-11eb-3eb9-a9ac41ff617e
# ╠═a840ad9a-5780-11eb-212b-3d40a6909569
# ╠═b08ed18e-5780-11eb-1a6d-93ccea6b4b5b
# ╠═d01ba77c-5780-11eb-31c7-edd964c2dd1b
# ╟─d695d7a4-5782-11eb-3587-c92103d9d10d
# ╠═343c022a-5783-11eb-1b61-11e3fe34a6b2
# ╟─000f1b12-5784-11eb-3c69-473702025c78
# ╠═47013696-5783-11eb-0a7e-05a6cee34e9f
# ╠═56a95004-5783-11eb-0ce8-cb5dc50488d8
# ╟─424491a6-5784-11eb-1f89-1dd15f770409
