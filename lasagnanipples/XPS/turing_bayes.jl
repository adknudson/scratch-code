### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 76df29cc-7ee3-11eb-289f-33e76a973439
using Turing, Optim

# ╔═╡ a1a1d83a-7ee3-11eb-232b-fb127d5f9c3b
begin
	using DataFrames
	import XLSX
	
	df = DataFrame(XLSX.readtable("data/pmma2.xlsx", "Sheet1")...) |>
		m->rename!(m, Symbol("counts-background") => :BR) |>
		m->sort!(m, [:BE])
	df.BR_pos = max.(df.BR, 0)
	df2 = df[23:end,:]
	x = Float64.(df2.BE)
	y = Float64.(df2.BR_pos)
end;

# ╔═╡ c84aa5de-7ee3-11eb-3124-6f91b4c7e254
md"""
## Model

$\begin{equation}
G(x; \mu, \sigma) = \exp\left(-\log(2) \cdot \left(\frac{x - \mu}{\sigma}\right)^2\right)
\end{equation}$

$\begin{equation}
L(x; \mu, \sigma) = \frac{1}{1 + \left(\frac{x - \mu}{\sigma}\right)^2}
\end{equation}$

$\begin{equation}
y(x) = \sum_{i=1}^{n} \left[m A_i L(x; \mu_i, \sigma_i) + (1-m) A_i G(x;\mu_i, \sigma_i)\right]
\end{equation}$
"""

# ╔═╡ 1c807312-7ee5-11eb-18a0-6bf944f16960
md"""
## Turing

### Two-Peak Model
"""

# ╔═╡ 3799b726-7ee5-11eb-36b7-b59c4fd84228
@model function two_peak_model(x, y)
	m ~ Beta(1, 1)
	
	A₁ ~ Normal(60_000, 5_000)
	μ₁ ~ Normal(285, 1)
	σ₁ ~ Exponential(1)
	
	A₂ ~ Normal(15_000, 1_000)
	μ₂ ~ Normal(288, 1)
	σ₂ ~ Exponential(1)
	
	G(x, μ, σ) = exp(-log(2)*((x-μ)/σ)^2)
	L(x, μ, σ) = 1 / (1 + ((x-μ)/σ)^2)
	LG(x, m, μ, σ) = m*L(x,μ,σ) + (1-m)*G(x,μ,σ)
	
	N = length(y)
	for n in 1:N
		μ = A₁ * LG(x[n], m, μ₁, σ₁) + A₂ * LG(x[n], m, μ₂, σ₂)
		y[n] ~ Normal(μ, 100)
	end
end

# ╔═╡ 865488aa-7ee8-11eb-1b22-a1a7107e3cdc
model_2 = two_peak_model(x, y)

# ╔═╡ b174a800-7ee8-11eb-2c44-c96fa9bb0bcf
optimize(model_2, MLE())

# ╔═╡ c70931ae-7ee8-11eb-3b68-2176ddc94be7
optimize(model_2, MAP())

# ╔═╡ e03bafc6-7ee8-11eb-3e53-a3fbe2df8155
md"""
### Four-Peak Model
"""

# ╔═╡ e8639682-7ee8-11eb-0982-49a0c46b3820
@model function four_peak_model(x, y)
	m ~ Beta(0.5, 0.5)
	
	A₁ ~ Normal(10_000, 1_000)
	μ₁ ~ Normal(283, 1)
	σ₁ ~ Exponential(1)
	
	A₂ ~ Normal(60_000, 1_000)
	μ₂ ~ Normal(284, 1)
	σ₂ ~ Exponential(1)
	
	A₃ ~ Normal(20_000, 1_000)
	μ₃ ~ Normal(286, 1)
	σ₃ ~ Exponential(1)
	
	A₄ ~ Normal(16_000, 1_000)
	μ₄ ~ Normal(288, 1)
	σ₄ ~ Exponential(1)
	
	G(x, μ, σ) = exp(-log(2)*((x-μ)/σ)^2)
	L(x, μ, σ) = 1 / (1 + ((x-μ)/σ)^2)
	LG(x, m, μ, σ) = m*L(x,μ,σ) + (1-m)*G(x,μ,σ)
	
	N = length(y)
	for n in 1:N
		μ = A₁ * LG(x[n], m, μ₁, σ₁) + 
		    A₂ * LG(x[n], m, μ₂, σ₂) +
			A₃ * LG(x[n], m, μ₃, σ₃) +
			A₄ * LG(x[n], m, μ₄, σ₄)
		y[n] ~ Normal(μ, 100)
	end
end

# ╔═╡ 5032754c-7ee9-11eb-220d-41b67ab39674
model_4 = four_peak_model(x, y)

# ╔═╡ 6123e9b4-7ee9-11eb-2ab6-61a725d6d7a2
optimize(model_4, MAP())

# ╔═╡ 9c02bc42-7eec-11eb-004b-fd19183c1222


# ╔═╡ Cell order:
# ╠═76df29cc-7ee3-11eb-289f-33e76a973439
# ╠═a1a1d83a-7ee3-11eb-232b-fb127d5f9c3b
# ╟─c84aa5de-7ee3-11eb-3124-6f91b4c7e254
# ╟─1c807312-7ee5-11eb-18a0-6bf944f16960
# ╠═3799b726-7ee5-11eb-36b7-b59c4fd84228
# ╠═865488aa-7ee8-11eb-1b22-a1a7107e3cdc
# ╠═b174a800-7ee8-11eb-2c44-c96fa9bb0bcf
# ╠═c70931ae-7ee8-11eb-3b68-2176ddc94be7
# ╟─e03bafc6-7ee8-11eb-3e53-a3fbe2df8155
# ╠═e8639682-7ee8-11eb-0982-49a0c46b3820
# ╠═5032754c-7ee9-11eb-220d-41b67ab39674
# ╠═6123e9b4-7ee9-11eb-2ab6-61a725d6d7a2
# ╠═9c02bc42-7eec-11eb-004b-fd19183c1222
