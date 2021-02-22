### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ c835bbfe-578f-11eb-2110-5b04a83ab737
using MvSim, Distributions

# ╔═╡ 47a52058-5792-11eb-343d-cfbcafac905b
md"""# Arbitrary GSD Encoding

The following three distributions are used as example by Xioa and Zhou in their paper on matching the Pearson correlation. I use them here to show that arbitrarily encoding a distribution as a GS-Distribution is not always necessary, and even detrimental to the goal.
"""

# ╔═╡ eaf30156-578f-11eb-2438-03902ba01039
begin
	dA = Beta(2, 3)
    dB = Binomial(2, 0.2)
    dC = Binomial(20, 0.2)
	
	gA = GSDistribution(dA)
	gB = GSDistribution(dB)
	gC = GSDistribution(dC)
end;

# ╔═╡ e8989dc0-5790-11eb-201b-dd20da2c4e33
md"""---

$Beta(2, 3)$

The Beta distribution is continuous, so already does not need to be approximated.
"""

# ╔═╡ 07b3de50-5790-11eb-3d91-5b7e3c87eea3
cor_bounds(dA, dA), cor_bounds(gA, gA)

# ╔═╡ d554c3d8-5790-11eb-0291-538cd218e4d3
pearson_match(-0.9, dA, dA), pearson_match(-0.9, gA, gA)

# ╔═╡ fe7e3e92-5790-11eb-3c7e-87043127619f
md"""---

$Binomial(2, 0.2)$

This is equivalent to a $Bernoulli(0.2)$ distribution.
"""

# ╔═╡ 1c67668c-5790-11eb-2d6f-f7ee2cd6db35
cor_bounds(dB, dB), cor_bounds(gB, gB)

# ╔═╡ 34c10e5e-5790-11eb-1c65-75df56991549
pearson_match(-0.5, dB, dB), pearson_match(-0.5, gB, gB)

# ╔═╡ a205016e-5790-11eb-388d-33b7e25b9a27
md"""**Observation**

GS-Distributions do not do well to match discrete distributions with *very* small support sets (e.g. Binomial(2, 0.2)

---

$Binomial(20, 0.2)$
"""

# ╔═╡ 2c307aea-5790-11eb-3f54-d77501191efb
cor_bounds(dC, dC), cor_bounds(gC, gC)

# ╔═╡ 2d78fa48-5791-11eb-37b0-1f28fda23167
pearson_match(-0.9, dC, dC), pearson_match(-0.9, gC, gC)

# ╔═╡ 402d6534-5791-11eb-3fb4-ab85ce29943a
md"""**Observation**
As the support set grows larger, so too does the accuracy of the GS-Distribution. In this case, the GS-Distribution is still overconfident in the range of correlations that are possible, but does well to match the true distribution. However, this may just be becuase the Binomial distribution has a larger support, and in general permit a wider range of correlations.
"""

# ╔═╡ 621e8052-5793-11eb-211f-dfc28e9320f4
md"""## Other Distributions"""

# ╔═╡ 6c42d920-5793-11eb-19e8-e1c3d771aa53
begin
	dE = LogNormal(3, 1)
	dF = NegativeBinomial(4, 0.02)
	dG = FDist(7, 5)
	
	gE = GSDistribution(dE)
	gF = GSDistribution(dF)
	gG = GSDistribution(dG)
end;

# ╔═╡ 72efadd0-5794-11eb-24c5-219bad38cf22
md"""---

$LogNormal(3, 1)$"""

# ╔═╡ b983bdd2-5793-11eb-2b3e-63ba0dbe7388
gE

# ╔═╡ 9ab7d62c-5793-11eb-29a2-d3fea40e6c99
cor_bounds(dE, dE), cor_bounds(gE, gE)

# ╔═╡ aabd7324-5793-11eb-0de6-9bdfe23721c7
pearson_match(-0.3, dE, dE), pearson_match(-0.3, gE, gE)

# ╔═╡ 56429d3c-5794-11eb-0728-d31738bfc30e
mean(dE), var(dE)

# ╔═╡ 5c511ef4-5794-11eb-21a7-fb5f0a56a24c
mean(gE), var(gE)

# ╔═╡ 7cd6f1b4-5794-11eb-1183-f560107c8ca8
md"""**Observation**

Again, encoding an already continuous distribution results in worse pearson mapping estimates.

---

$NegativeBinomial(4, 0.02)$
"""

# ╔═╡ d07dd716-5793-11eb-1137-5d940d60cff5
gF

# ╔═╡ d52721c0-5793-11eb-086f-83bbfa66bb4b
cor_bounds(dF, dF), cor_bounds(gF, gF)

# ╔═╡ db62607a-5793-11eb-3359-f3f5c6c3ce0f
MvSim._pearson_match(-0.8, dF, dF, 7), pearson_match(-0.8, gF, gF)

# ╔═╡ ecfc2e42-5793-11eb-036c-3153d97f74b1
md"""**Observation**

This is the type of distribution that GSD is perfectly suitable for.

---

$FDist(7, 5)$

Note: The variance for $F(d_1, d_2)$ does not exist for $d_2 \le 4$
"""

# ╔═╡ 1e200574-5795-11eb-3d9e-b97ca42437f5
gG

# ╔═╡ 226fd352-5795-11eb-15a7-e99b1d9e22ea
cor_bounds(dG, dG), cor_bounds(gG, gG)

# ╔═╡ 2a9fbbbc-5795-11eb-341c-739c01e9821e
pearson_bounds(gG, gG)

# ╔═╡ 6dbe27f4-5796-11eb-04d7-510bac7d0074
pearson_match(-0.2, dG, dG), pearson_match(-0.2, gG, gG)

# ╔═╡ Cell order:
# ╟─47a52058-5792-11eb-343d-cfbcafac905b
# ╠═c835bbfe-578f-11eb-2110-5b04a83ab737
# ╠═eaf30156-578f-11eb-2438-03902ba01039
# ╟─e8989dc0-5790-11eb-201b-dd20da2c4e33
# ╠═07b3de50-5790-11eb-3d91-5b7e3c87eea3
# ╠═d554c3d8-5790-11eb-0291-538cd218e4d3
# ╟─fe7e3e92-5790-11eb-3c7e-87043127619f
# ╠═1c67668c-5790-11eb-2d6f-f7ee2cd6db35
# ╠═34c10e5e-5790-11eb-1c65-75df56991549
# ╟─a205016e-5790-11eb-388d-33b7e25b9a27
# ╠═2c307aea-5790-11eb-3f54-d77501191efb
# ╠═2d78fa48-5791-11eb-37b0-1f28fda23167
# ╟─402d6534-5791-11eb-3fb4-ab85ce29943a
# ╟─621e8052-5793-11eb-211f-dfc28e9320f4
# ╠═6c42d920-5793-11eb-19e8-e1c3d771aa53
# ╟─72efadd0-5794-11eb-24c5-219bad38cf22
# ╠═b983bdd2-5793-11eb-2b3e-63ba0dbe7388
# ╠═9ab7d62c-5793-11eb-29a2-d3fea40e6c99
# ╠═aabd7324-5793-11eb-0de6-9bdfe23721c7
# ╠═56429d3c-5794-11eb-0728-d31738bfc30e
# ╠═5c511ef4-5794-11eb-21a7-fb5f0a56a24c
# ╟─7cd6f1b4-5794-11eb-1183-f560107c8ca8
# ╠═d07dd716-5793-11eb-1137-5d940d60cff5
# ╠═d52721c0-5793-11eb-086f-83bbfa66bb4b
# ╠═db62607a-5793-11eb-3359-f3f5c6c3ce0f
# ╟─ecfc2e42-5793-11eb-036c-3153d97f74b1
# ╠═1e200574-5795-11eb-3d9e-b97ca42437f5
# ╠═226fd352-5795-11eb-15a7-e99b1d9e22ea
# ╠═2a9fbbbc-5795-11eb-341c-739c01e9821e
# ╠═6dbe27f4-5796-11eb-04d7-510bac7d0074
