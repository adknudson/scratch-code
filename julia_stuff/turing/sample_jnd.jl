### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 42bfc99e-dc40-11ea-335d-9dcefe11b256
using Turing, Distributions, StatsPlots, DataFrames

# ╔═╡ 3c208a60-dc40-11ea-3da4-4dcee50f156b
pwd()

# ╔═╡ 23050bc8-dc40-11ea-2128-0b8dc9dcce42
import Pkg; Pkg.activate(pwd());

# ╔═╡ aaeeb14c-dc40-11ea-2bb4-ab01520f4d18
begin
	μ_a, σ_a = 0, 0.05
	μ_aG, σ_aG = 0, 0.005
	μ_aT, σ_aT = 0, 0.025
	μ_aTG, σ_aTG = 0, 0.005
end;

# ╔═╡ bd3d9714-dc40-11ea-1d32-65e1fc70c004
@model delta() = begin
	a ~ Normal(μ_a, σ_a)
	aT ~ Normal(μ_aT, σ_aT)
	sd_aG ~ truncated(Cauchy(0, σ_aG), 0, Inf)
	sd_aTG ~ truncated(Cauchy(0, σ_aTG), 0, Inf)
	aG ~ Normal(μ_aG, sd_aG)
	aTG ~ Normal(μ_aTG, sd_aTG)
end

# ╔═╡ d84271ce-dc40-11ea-11bf-f70b30f2c4d1
iter, ϵ, τ = 1000, 0.005, 10

# ╔═╡ ea0ebd9a-dc40-11ea-2477-659dfe5abc0c
chain = sample(delta(), Prior(), iter)

# ╔═╡ 917af04e-dc41-11ea-1488-17d0190189cd
function pss(chain, trt)
	c = DataFrame(chain)
	s = c[:a] + c[:aG]
	if trt
		s += c[:aT] + c[:aTG]
	end
	return s
end

# ╔═╡ 10401b8e-dc42-11ea-17d6-955b74fb8598
histogram(pss(chain, false))

# ╔═╡ fffcf318-dc42-11ea-2373-2f8a7a5c4f66
histogram(pss(chain, true))

# ╔═╡ 12de9368-dc43-11ea-283a-ebb5d0113653
DataFrame(chain)

# ╔═╡ 62537328-dc45-11ea-378c-73810ed0c294
chain[:a].value + chain[:aT].value

# ╔═╡ 97e1ffb8-dc46-11ea-3208-497ea366a682


# ╔═╡ 8105a24a-dc46-11ea-0131-6db17e870179


# ╔═╡ Cell order:
# ╠═3c208a60-dc40-11ea-3da4-4dcee50f156b
# ╠═23050bc8-dc40-11ea-2128-0b8dc9dcce42
# ╠═42bfc99e-dc40-11ea-335d-9dcefe11b256
# ╠═aaeeb14c-dc40-11ea-2bb4-ab01520f4d18
# ╠═bd3d9714-dc40-11ea-1d32-65e1fc70c004
# ╠═d84271ce-dc40-11ea-11bf-f70b30f2c4d1
# ╠═ea0ebd9a-dc40-11ea-2477-659dfe5abc0c
# ╠═917af04e-dc41-11ea-1488-17d0190189cd
# ╠═10401b8e-dc42-11ea-17d6-955b74fb8598
# ╠═fffcf318-dc42-11ea-2373-2f8a7a5c4f66
# ╠═12de9368-dc43-11ea-283a-ebb5d0113653
# ╠═62537328-dc45-11ea-378c-73810ed0c294
# ╠═97e1ffb8-dc46-11ea-3208-497ea366a682
# ╠═8105a24a-dc46-11ea-0131-6db17e870179
