### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 01fec238-6c21-11eb-24fa-ed08b1f8afaf
using DifferentialEquations, DiffEqFlux, Optim, Flux, GalacticOptim

# ╔═╡ 05bcf2d0-6c21-11eb-3e71-5545bc8aaa52
using Plots

# ╔═╡ f9e7248a-6c20-11eb-30a7-a3e96f704278
md"""# Scientific Machine Learning"""

# ╔═╡ 07d40cb4-6c21-11eb-2822-310bab39661e
function latka_volterra!(du, u, p, t)
	r, w = u
	α, β, γ, δ = p
	du[1] = dr = α*r - β*r*w
	du[2] = dw = γ*r*w - δ*w
	nothing
end

# ╔═╡ 42f18152-6c21-11eb-1558-573d33235ac7
begin
	u₀ = [1.0, 1.0]
	tspan = (0.0, 10.0)
	p = [1.5, 1.0, 3.0, 1.0]
end

# ╔═╡ 57915d76-6c21-11eb-35ca-d9d14a2cedf1
prob = ODEProblem(latka_volterra!, u₀, tspan, p);

# ╔═╡ 6356a76a-6c21-11eb-3ebc-0fb4902d1868
sol = solve(prob, saveat=0.1);

# ╔═╡ 9425b9f2-6c22-11eb-364a-8983fce816f0
df = Array(sol)

# ╔═╡ 74e36bf4-6c22-11eb-3f46-0f20dc13c76b
plot(sol); scatter!(sol.t, df')

# ╔═╡ 69629ac4-6c21-11eb-2aa6-e3f324b31274
tmp_prob = remake(prob, p=[1.2, 0.8, 2.5, 0.8]);

# ╔═╡ 830cbe0a-6c21-11eb-079f-0b429736affb
tmp_sol = solve(tmp_prob);

# ╔═╡ 6ef52d98-6c22-11eb-1567-f9da3c7bf227
plot(tmp_sol); scatter!(sol.t, df')

# ╔═╡ 722ba244-6c22-11eb-05e9-f994f27d3781
function loss(p)
	tmp_prob = remake(prob, p=p)
	tmp_sol = solve(tmp_prob, saveat=0.1)
	sum(abs2, Array(tmp_sol) - df)
end

# ╔═╡ 48eda524-6c24-11eb-31a7-cb2e07828d99
pinit = [1.2, 0.8, 2.5, 0.8]

# ╔═╡ 038e6640-6c28-11eb-1f05-ab000e9698be
opt_prob = OptimizationProblem(loss, u₀,  pinit, lb = 0.5ones(4), ub=4.0ones(4))

# ╔═╡ 562571f0-6c28-11eb-3433-1d046d1aaec9
solve(opt_prob, BBO())

# ╔═╡ Cell order:
# ╟─f9e7248a-6c20-11eb-30a7-a3e96f704278
# ╠═01fec238-6c21-11eb-24fa-ed08b1f8afaf
# ╠═05bcf2d0-6c21-11eb-3e71-5545bc8aaa52
# ╠═07d40cb4-6c21-11eb-2822-310bab39661e
# ╠═42f18152-6c21-11eb-1558-573d33235ac7
# ╠═57915d76-6c21-11eb-35ca-d9d14a2cedf1
# ╠═6356a76a-6c21-11eb-3ebc-0fb4902d1868
# ╠═9425b9f2-6c22-11eb-364a-8983fce816f0
# ╠═74e36bf4-6c22-11eb-3f46-0f20dc13c76b
# ╠═69629ac4-6c21-11eb-2aa6-e3f324b31274
# ╠═830cbe0a-6c21-11eb-079f-0b429736affb
# ╠═6ef52d98-6c22-11eb-1567-f9da3c7bf227
# ╠═722ba244-6c22-11eb-05e9-f994f27d3781
# ╠═48eda524-6c24-11eb-31a7-cb2e07828d99
# ╠═038e6640-6c28-11eb-1f05-ab000e9698be
# ╠═562571f0-6c28-11eb-3433-1d046d1aaec9
