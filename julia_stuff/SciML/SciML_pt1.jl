### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ ccc94012-6c15-11eb-112d-c1c953f509df
using DifferentialEquations

# ╔═╡ 4596a432-6c17-11eb-2f72-b5f1635c3d17
using Plots

# ╔═╡ e3b4f160-6c1b-11eb-010c-ad2ea3633372
md"""# Scientific Machine Learning"""

# ╔═╡ f197f980-6c1b-11eb-09ca-cb13d81ae9f9
md"""## Simple ODE"""

# ╔═╡ d500efee-6c15-11eb-2cfa-7d92e1861fd7
function latka_volterra!(du, u, p, t)
	r, w = u
	α, β, γ, δ = p
	du[1] = dr = α*r - β*r*w
	du[2] = dw = γ*r*w - δ*w
end

# ╔═╡ e3bca37e-6c16-11eb-00f3-d91cf4b22978
u₀ = [1.0, 1.0]

# ╔═╡ 00784964-6c17-11eb-0665-b5670ff5fa06
tspan = (0.0, 10.0)

# ╔═╡ 12e8ed9c-6c17-11eb-2e14-f93640b1afab
p = [1.5, 1.0, 3.0, 1.0]

# ╔═╡ 05d2ab3e-6c17-11eb-2209-2127a8bf2a6a
prob = ODEProblem(latka_volterra!, u₀, tspan, p)

# ╔═╡ 2209cae4-6c17-11eb-0403-7bfbf985aa9c
sol = solve(prob)

# ╔═╡ f65a5c56-6c16-11eb-197c-1b261e668b1c
plot(sol)

# ╔═╡ 432d8a9e-6c17-11eb-09dc-f376c375b272
plot(sol, vars=(1,2))

# ╔═╡ 90529334-6c17-11eb-12d8-1d6d17d37f06
sol.t[5], sol[5]

# ╔═╡ a61e377a-6c17-11eb-399c-9923002e7c86
sol(1.2)

# ╔═╡ fb3056a4-6c1b-11eb-3095-a74f112bd4d0
md"""## Stochastic ODE"""

# ╔═╡ b2088bee-6c17-11eb-384b-97ce092656d7
function multiplicative_noise!(du, u, p, t)
	r, w = u
	du[1] = 0.3*r
	du[2] = 0.3*w
end

# ╔═╡ 0c88dd16-6c19-11eb-342e-e1333761f22d
prob2 = SDEProblem(latka_volterra!, multiplicative_noise!, u₀, tspan, p)

# ╔═╡ 4355f722-6c19-11eb-3bd1-b3b6e8670003
sol2 = solve(prob2)

# ╔═╡ 46e8218a-6c19-11eb-2cee-a990d7f5e96c
plot(sol2)

# ╔═╡ 3fbfd996-6c19-11eb-1643-dbeb69bb8979
plot(sol2, vars=(1,2))

# ╔═╡ 08227964-6c1c-11eb-2130-57146ee7d1a2
md"""## Ensemble SDE"""

# ╔═╡ 805892c4-6c19-11eb-30da-3d5cb6baa4a5
ensembleproblem = EnsembleProblem(prob2)

# ╔═╡ 8af979c6-6c19-11eb-057c-f1e397c84e6e
sol3 = solve(ensembleproblem, SOSRI(), trajectories=1000);

# ╔═╡ b8928e72-6c19-11eb-230c-67bf976e9651
plot(sol3)

# ╔═╡ e96feb16-6c19-11eb-150a-398caad51a66
summ = EnsembleSummary(sol3);

# ╔═╡ f0298278-6c19-11eb-3637-9da55caafc4e
plot(summ)

# ╔═╡ 1252eb1c-6c1c-11eb-35f3-89b0734141e8
md"""## Delayed ODE"""

# ╔═╡ cb0bfbb4-6c1a-11eb-3cef-c54c633468a1
τ = 1.0

# ╔═╡ ef01c30a-6c1a-11eb-2df4-5be6f6ee4fa0
begin
	h(p, t) = [1.0, 1.0]
	h(p, t; idxs=1) = 1.0
end

# ╔═╡ 164ea258-6c1a-11eb-0969-0d8ddfb7fadd
function latka_volterra_delay!(du, u, h, p, t)
	r, w = u
	delay_r = h(p, t - τ; idxs=1)
	α, β, γ, δ = p
	du[1] = dr = α*delay_r - β*r*w
	du[2] = dw = γ*r*w - δ*w
end

# ╔═╡ cdc8138c-6c1b-11eb-1d13-25502826c2e1
tspan2 = (0.0, 20.0)

# ╔═╡ 28cd3194-6c1b-11eb-0c13-53eba25b96ab
prob4 = DDEProblem(latka_volterra_delay!, u₀, h, tspan2, p, constant_lag = [τ])

# ╔═╡ 5c8ea852-6c1b-11eb-36d6-83675ace65bb
sol4 = solve(prob4)

# ╔═╡ 62ed1bd4-6c1b-11eb-1498-791e18587bbe
plot(sol4)

# ╔═╡ ad3a3550-6c1b-11eb-1c86-1f9b676a8542
plot(sol4, vars=(1,2))

# ╔═╡ b8358bee-6c1b-11eb-0d0b-67eda8c3b68c
md"""## Callback ODE"""

# ╔═╡ 21063d80-6c1c-11eb-22c6-498f07596df5
rabbit_season_condition(u, t, integrator) = u[2] - 4

# ╔═╡ 5813bb54-6c1c-11eb-354b-4bdd3fafff6c
rabbit_season_affect!(integrator) = integrator.u[2] *= 0.5

# ╔═╡ 796d5e24-6c1c-11eb-02d8-99c6ad0e081a
rabbit_callback = ContinuousCallback(rabbit_season_condition, rabbit_season_affect!)

# ╔═╡ 9ab94e1a-6c1c-11eb-3de6-5b89adf05d46
sol5 = solve(prob4, callback = rabbit_callback)

# ╔═╡ a9ce0424-6c1c-11eb-27a4-61bc431afbf0
plot(sol5)

# ╔═╡ Cell order:
# ╟─e3b4f160-6c1b-11eb-010c-ad2ea3633372
# ╠═ccc94012-6c15-11eb-112d-c1c953f509df
# ╠═4596a432-6c17-11eb-2f72-b5f1635c3d17
# ╟─f197f980-6c1b-11eb-09ca-cb13d81ae9f9
# ╠═d500efee-6c15-11eb-2cfa-7d92e1861fd7
# ╠═e3bca37e-6c16-11eb-00f3-d91cf4b22978
# ╠═00784964-6c17-11eb-0665-b5670ff5fa06
# ╠═12e8ed9c-6c17-11eb-2e14-f93640b1afab
# ╠═05d2ab3e-6c17-11eb-2209-2127a8bf2a6a
# ╠═2209cae4-6c17-11eb-0403-7bfbf985aa9c
# ╠═f65a5c56-6c16-11eb-197c-1b261e668b1c
# ╠═432d8a9e-6c17-11eb-09dc-f376c375b272
# ╠═90529334-6c17-11eb-12d8-1d6d17d37f06
# ╠═a61e377a-6c17-11eb-399c-9923002e7c86
# ╟─fb3056a4-6c1b-11eb-3095-a74f112bd4d0
# ╠═b2088bee-6c17-11eb-384b-97ce092656d7
# ╠═0c88dd16-6c19-11eb-342e-e1333761f22d
# ╠═4355f722-6c19-11eb-3bd1-b3b6e8670003
# ╠═46e8218a-6c19-11eb-2cee-a990d7f5e96c
# ╠═3fbfd996-6c19-11eb-1643-dbeb69bb8979
# ╟─08227964-6c1c-11eb-2130-57146ee7d1a2
# ╠═805892c4-6c19-11eb-30da-3d5cb6baa4a5
# ╠═8af979c6-6c19-11eb-057c-f1e397c84e6e
# ╠═b8928e72-6c19-11eb-230c-67bf976e9651
# ╠═e96feb16-6c19-11eb-150a-398caad51a66
# ╠═f0298278-6c19-11eb-3637-9da55caafc4e
# ╟─1252eb1c-6c1c-11eb-35f3-89b0734141e8
# ╠═cb0bfbb4-6c1a-11eb-3cef-c54c633468a1
# ╠═ef01c30a-6c1a-11eb-2df4-5be6f6ee4fa0
# ╠═164ea258-6c1a-11eb-0969-0d8ddfb7fadd
# ╠═cdc8138c-6c1b-11eb-1d13-25502826c2e1
# ╠═28cd3194-6c1b-11eb-0c13-53eba25b96ab
# ╠═5c8ea852-6c1b-11eb-36d6-83675ace65bb
# ╠═62ed1bd4-6c1b-11eb-1498-791e18587bbe
# ╠═ad3a3550-6c1b-11eb-1c86-1f9b676a8542
# ╟─b8358bee-6c1b-11eb-0d0b-67eda8c3b68c
# ╠═21063d80-6c1c-11eb-22c6-498f07596df5
# ╠═5813bb54-6c1c-11eb-354b-4bdd3fafff6c
# ╠═796d5e24-6c1c-11eb-02d8-99c6ad0e081a
# ╠═9ab94e1a-6c1c-11eb-3de6-5b89adf05d46
# ╠═a9ce0424-6c1c-11eb-27a4-61bc431afbf0
