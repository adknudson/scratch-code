### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 682c3a18-7ebc-11eb-1d37-bbec0f9fe9f2
begin
	using DataFrames
	using Plots
	using LsqFit
	import XLSX
end

# ╔═╡ c1e9c012-7ebb-11eb-2cd0-db0f2bfe2370
md"""
# X-ray Photoelectron Spectroscopy
"""

# ╔═╡ ec679ab2-7eca-11eb-3cf1-4305d55ce10b
md"""
## Model

$\begin{equation}
G(x; \mu, \sigma) = 2^{-\left(\frac{2(x - \mu)}{\sigma}\right)^2}
\end{equation}$

$\begin{equation}
L(x; \mu, \sigma) = \frac{1}{1 + \left(\frac{2(x - \mu)}{\sigma}\right)^2}
\end{equation}$

$\begin{equation}
y(x) = \sum_{i=1}^{n} \left[m A_i L(x; \mu_i, \sigma_i) + (1-m) A_i G(x;\mu_i, \sigma_i)\right]
\end{equation}$
"""

# ╔═╡ f43316f8-7ed0-11eb-2b52-c3cdc03b5338
begin
	@. G(x, μ, σ) = 2^(-(2(x-μ)/σ)^2)
	@. L(x, μ, σ) = 1 / (1 + (2(x-μ)/σ)^2)
	@. LG(x, m, μ, σ) = m*L(x,μ,σ) + (1-m)*G(x,μ,σ)
end;

# ╔═╡ ad2294ca-7ed8-11eb-0eba-fbfef093e3f6
md"""
## Data
"""

# ╔═╡ 9554ffc0-7ebc-11eb-2bb0-b382b5f40580
df = DataFrame(XLSX.readtable("data/pmma2.xlsx", "Sheet1")...) |>
	m->rename!(m, Symbol("counts-background") => :BR) |>
	m->sort!(m, [:BE])

# ╔═╡ ce94cabc-7ed1-11eb-356a-b9d928fd612d
# Replace negative counts with zero
df.BR_pos = max.(df.BR, 0); 

# ╔═╡ 5f55bafa-7ecf-11eb-37cf-e9a42956e9e1
plot(df.:BE, df.:BR_pos, legend=false, title="Data")

# ╔═╡ 92439de4-7edc-11eb-0411-ad33a032a784
# Cut off the beginning noise
df.BR_pos[22:end]

# ╔═╡ b58ca64c-7edc-11eb-0889-5df268625590
df2 = df[23:end,:]

# ╔═╡ d9b6d300-7ed0-11eb-1efa-83a867f9cb88
md"""
### Two-Peak Model
"""

# ╔═╡ bf8792a0-7ed8-11eb-0077-27e6e7513f3c
function two_peak_model(x, p)
	m, A₁, μ₁, σ₁, A₂, μ₂, σ₂ = p
	@. A₁*LG(x,m,μ₁,σ₁) + A₂*LG(x,m,μ₂,σ₂)
end

# ╔═╡ 2ec1ccb6-7ed3-11eb-0405-f73319e46826
md"""
### Four-Peak Model
"""

# ╔═╡ 389e1354-7ed3-11eb-2f15-8d1fab394086
function four_peak_model(x, p)
	m, A₁, μ₁, σ₁, A₂, μ₂, σ₂, A₃, μ₃, σ₃, A₄, μ₄, σ₄ = p
	@. A₁*LG(x,m,μ₁,σ₁) + 
	   A₂*LG(x,m,μ₂,σ₂) +
	   A₃*LG(x,m,μ₃,σ₃) +
	   A₄*LG(x,m,μ₄,σ₄)
end

# ╔═╡ 149cc904-7ed4-11eb-2fdd-df8f82e42f33
# Lower Bounds
lb = [
	0.0,
	minimum(df2.BR_pos), minimum(df2.BE), eps(),
	minimum(df2.BR_pos), minimum(df2.BE), eps(),
	minimum(df2.BR_pos), minimum(df2.BE), eps(),
	minimum(df2.BR_pos), minimum(df2.BE), eps()
];

# ╔═╡ 32c2c7c6-7ed4-11eb-261f-0b5f7171479c
# Upper Bounds
ub = [
	1.0,
	maximum(df2.BR_pos), maximum(df2.BE), 5.0,
	maximum(df2.BR_pos), maximum(df2.BE), 5.0,
	maximum(df2.BR_pos), maximum(df2.BE), 5.0,
	maximum(df2.BR_pos), maximum(df2.BE), 5.0
];

# ╔═╡ 24382f52-823a-11eb-2d1e-77696ae06804
BR_bar = sum(df.BR) / size(df,1)

# ╔═╡ c20105ae-7ed1-11eb-030e-ddb66def7bee
# Initial Values
p0_2 = [
	0.5, 
	BR_bar, 285.0, 1.5,
	BR_bar, 289.0, 1.5
];

# ╔═╡ 6da8a36c-7ed2-11eb-0ef0-6b848a6fa038
two_peak_sol = curve_fit(two_peak_model, df2.BE, df2.BR_pos, p0_2);

# ╔═╡ 92f0511a-7ed2-11eb-05d5-7df0a1c6a3f1
p2 = two_peak_sol.param;

# ╔═╡ 3a1ffc32-7ed9-11eb-3559-15c3e17bba5e
(
	m =p2[1], 
	A₁=p2[2], 
	μ₁=p2[3], 
	σ₁=p2[4], 
	A₂=p2[5], 
	μ₂=p2[6], 
	σ₂=p2[7]
)

# ╔═╡ 4c46e66c-7ed8-11eb-007e-5f520b09058b
begin
	plot(x->two_peak_model(x, two_peak_sol.param), 
		 minimum(df.:BE), maximum(df.:BE), lw=2,
	     label="LSQ Fit", title="Two-Peak Model")
	scatter!(df.:BE, df.:BR_pos, ms=2, label="Data")
end

# ╔═╡ 6ce25c06-7ed3-11eb-25e5-9d2cda7b7b6c
# Initial Values
p0_4 = [
	0.2, 
	BR_bar, 283.0, 1.5, 
	BR_bar, 284.0, 1.5,
	BR_bar, 285.0, 1.5,
	BR_bar, 288.0, 1.5
];

# ╔═╡ 927c0ade-7ed3-11eb-0b08-0749c1794b38
four_peak_sol = curve_fit(four_peak_model, df2.BE, df2.BR_pos, p0_4, 
	                      lower = lb, upper = ub)

# ╔═╡ d0a0829c-7ed4-11eb-2cf6-1da7bc3196fc
p4 = four_peak_sol.param;

# ╔═╡ df05d9fc-7ed8-11eb-0a05-151be93815e7
(
	m =p4[1], 
	A₁=p4[2], 
	μ₁=p4[3], 
	σ₁=p4[4], 
	A₂=p4[5], 
	μ₂=p4[6], 
	σ₂=p4[7], 
	A₃=p4[8], 
	μ₃=p4[9], 
	σ₃=p4[10], 
	A₄=p4[11], 
	μ₄=p4[12], 
	σ₄=p4[13]
)

# ╔═╡ 752136ae-7ed7-11eb-1c80-6bbfea50d432
begin
	plot(x->four_peak_model(x, four_peak_sol.param), 
		 minimum(df.:BE), maximum(df.:BE), lw=2,
	     label="LSQ Fit", title="Four-Peak Model")
	scatter!(df.:BE, df.:BR_pos, ms=2, label="Data")
end

# ╔═╡ Cell order:
# ╟─c1e9c012-7ebb-11eb-2cd0-db0f2bfe2370
# ╠═682c3a18-7ebc-11eb-1d37-bbec0f9fe9f2
# ╠═ec679ab2-7eca-11eb-3cf1-4305d55ce10b
# ╠═f43316f8-7ed0-11eb-2b52-c3cdc03b5338
# ╟─ad2294ca-7ed8-11eb-0eba-fbfef093e3f6
# ╠═9554ffc0-7ebc-11eb-2bb0-b382b5f40580
# ╠═ce94cabc-7ed1-11eb-356a-b9d928fd612d
# ╟─5f55bafa-7ecf-11eb-37cf-e9a42956e9e1
# ╠═92439de4-7edc-11eb-0411-ad33a032a784
# ╠═b58ca64c-7edc-11eb-0889-5df268625590
# ╟─d9b6d300-7ed0-11eb-1efa-83a867f9cb88
# ╠═bf8792a0-7ed8-11eb-0077-27e6e7513f3c
# ╠═c20105ae-7ed1-11eb-030e-ddb66def7bee
# ╠═6da8a36c-7ed2-11eb-0ef0-6b848a6fa038
# ╠═92f0511a-7ed2-11eb-05d5-7df0a1c6a3f1
# ╟─3a1ffc32-7ed9-11eb-3559-15c3e17bba5e
# ╟─4c46e66c-7ed8-11eb-007e-5f520b09058b
# ╟─2ec1ccb6-7ed3-11eb-0405-f73319e46826
# ╠═389e1354-7ed3-11eb-2f15-8d1fab394086
# ╠═149cc904-7ed4-11eb-2fdd-df8f82e42f33
# ╠═32c2c7c6-7ed4-11eb-261f-0b5f7171479c
# ╠═24382f52-823a-11eb-2d1e-77696ae06804
# ╠═6ce25c06-7ed3-11eb-25e5-9d2cda7b7b6c
# ╠═927c0ade-7ed3-11eb-0b08-0749c1794b38
# ╠═d0a0829c-7ed4-11eb-2cf6-1da7bc3196fc
# ╟─df05d9fc-7ed8-11eb-0a05-151be93815e7
# ╠═752136ae-7ed7-11eb-1c80-6bbfea50d432
