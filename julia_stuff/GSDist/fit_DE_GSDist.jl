### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 68a2a68a-7237-11eb-381a-2dea1a80b049
begin
	using Distributions, StatsPlots
	using DifferentialEquations
end

# ╔═╡ 734eebd6-723a-11eb-14eb-f9e995972c6a
md"""
The Generalized S-Distribution is characterized by the following differential equation:

$$\frac{du}{dt} = \alpha u^g \left(1 - u^k \right)^\gamma, \quad u(x_0) = F_0$$

Here $f(t) = du/dt$ where $f$ is the PDF of the distribution. We also have the boundary conditions:

$$\begin{align}
u(t_0) &= 0 \\
u(t_{end}) &= 1
\end{align}$$

The goal is to represent some probability distribution by the GSDist, specifically discrete distributions with large finite or infinite support. In such cases, $t_{end}$ can be set to a large value (say the 0.99 quantile).

Let's use the NegativeBinomial distribution as a test case:

$$Y \sim NB(20, 0.2)$$

The minimum is $0$ and the maximum is $\infty$. The median is 79 and the 0.01 and 0.99 quantiles are 40 and 133. We can then set the time span of this differential equation to

$$t \in (40, 133)$$

and the initial value

$$u(40) = 0.01$$

The other two boundary values become

$$u(79) = 0.5 \quad \mathrm{and} \quad u(133) = 0.99$$

The values for $\alpha, g, k, \gamma$ are given and are characteristic of a NB(20, 0.2) distribution.
"""

# ╔═╡ 45fad45c-724d-11eb-19c3-39b2facb7eb5
D = Gamma(20, 0.2)

# ╔═╡ 0c333696-723a-11eb-2278-2d121fe6007c
p = [
1.7859027133496952  # α
0.7809031488989574  # g
0.6907989061985794  # k
0.8642087292779282  # γ
]

# ╔═╡ 85b212fc-723b-11eb-39e9-639cf2f426f7
function gsd!(du, u, p, t)
	α, g, k, γ = p
	du[1] = α * u[1]^g * (1 - u[1]^k)^γ
end

# ╔═╡ 62112c32-724c-11eb-3c60-23f63b1c9c9c
# q = [0.01, 0.15, 0.85, 0.99]
q = [0.01, 0.5, 0.99]

# ╔═╡ f05376d4-7c7a-11eb-3fcc-375bf40eba61
x = Float64.(quantile(D, q))

# ╔═╡ e6e6265a-7c7a-11eb-0451-1fc7466fabcc
d = length(q) - 1

# ╔═╡ 4f125984-7248-11eb-25f6-f11b5727c538
P = [ODEProblem(gsd!, [q[i]], (x[i], x[i+1]), p) for i in 1:d]

# ╔═╡ 1d2eba36-724b-11eb-1a38-a722db6ed12d
S = [solve(prob_i) for prob_i in P];

# ╔═╡ a46d9e7a-724a-11eb-3bee-b7318707af35
begin
	xlim = (0, 10)
	plot(S[1],  xlim=xlim, linewidth=2)
	plot!(S[2], xlim=xlim, linewidth=2)
	# plot!(S[3],  xlim=xlim, linewidth=2)
	# plot!(S[4],  xlim=xlim, linewidth=2)
	# plot!(S[5],  xlim=xlim, linewidth=2)
	plot!(D, func=cdf, xlim=xlim, legend=:topleft, markersize=1.5)
end

# ╔═╡ 03e664ee-724d-11eb-1ded-7ff577067591
function new_piecewise_cdf(α, g, k, γ, dist; probs=[0.01, 0.15, 0.85, 0.99])
	p = [α, g, k, γ]
	cutpoint = Float64.(quantile(dist, probs))
	d = length(probs) - 1
	
	function f!(du, u, p, t)
		α, g, k, γ = p
		du[1] = α * u[1]^g * (1 - u[1]^k)^γ
	end
	
	P = [ODEProblem(f!, [probs[i]], (cutpoint[i], cutpoint[i+1]), p) for i in 1:d]
	S = [solve(x) for x in P]
	
	# Make a piecewise CDF
	x -> begin
		x < cutpoint[1]   && return max(S[1](x)[1],   0.0)
		x > cutpoint[end] && return min(S[end](x)[1], 1.0)
		idx = findfirst(cutpoint[1:end-1] .≤ x .≤ cutpoint[2:end])
		return S[idx](x)[1]
	end
end

# ╔═╡ 6ac2bd84-724f-11eb-24ce-037a1203ff04
F = new_piecewise_cdf(p..., D)

# ╔═╡ a87c1f18-7c7b-11eb-2a0e-4746280d8acc
F.(0:1:10)

# ╔═╡ b5c61ad4-7c7b-11eb-03e2-c31300449617
cdf(D, 0:1:10)

# ╔═╡ Cell order:
# ╠═68a2a68a-7237-11eb-381a-2dea1a80b049
# ╟─734eebd6-723a-11eb-14eb-f9e995972c6a
# ╠═45fad45c-724d-11eb-19c3-39b2facb7eb5
# ╠═0c333696-723a-11eb-2278-2d121fe6007c
# ╠═85b212fc-723b-11eb-39e9-639cf2f426f7
# ╠═62112c32-724c-11eb-3c60-23f63b1c9c9c
# ╠═f05376d4-7c7a-11eb-3fcc-375bf40eba61
# ╠═e6e6265a-7c7a-11eb-0451-1fc7466fabcc
# ╠═4f125984-7248-11eb-25f6-f11b5727c538
# ╠═1d2eba36-724b-11eb-1a38-a722db6ed12d
# ╠═a46d9e7a-724a-11eb-3bee-b7318707af35
# ╠═03e664ee-724d-11eb-1ded-7ff577067591
# ╠═6ac2bd84-724f-11eb-24ce-037a1203ff04
# ╠═a87c1f18-7c7b-11eb-2a0e-4746280d8acc
# ╠═b5c61ad4-7c7b-11eb-03e2-c31300449617
