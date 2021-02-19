### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 68a2a68a-7237-11eb-381a-2dea1a80b049
begin
	using Distributions, StatsPlots
	using DifferentialEquations, BoundaryValueDiffEq
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
D = NegativeBinomial(20, 0.2)

# ╔═╡ 0c333696-723a-11eb-2278-2d121fe6007c
p = [
0.08353097172748393  # α
0.7939392014863037   # g
0.661406005420478    # k
0.8694208742687423   # γ
]

# ╔═╡ 85b212fc-723b-11eb-39e9-639cf2f426f7
function gsd!(du, u, p, t)
	α, g, k, γ = p
	du[1] = α * u[1]^g * (1 - u[1]^k)^γ
end

# ╔═╡ 62112c32-724c-11eb-3c60-23f63b1c9c9c
q = [0.01, 0.15, 0.85, 0.99]

# ╔═╡ e2032e64-724b-11eb-39e8-b56ca11e737f
x = Float64[quantile(NegativeBinomial(20, 0.2), q)...]

# ╔═╡ 370e4182-7260-11eb-25c1-b9c561abd7ec
x[1]

# ╔═╡ 4f125984-7248-11eb-25f6-f11b5727c538
begin
	lo  = ODEProblem(gsd!, [q[1]], (x[1], x[2]), p)
	mid = ODEProblem(gsd!, [q[2]], (x[2], x[3]), p)
	up  = ODEProblem(gsd!, [q[3]], (x[3], x[4]), p)
end;

# ╔═╡ 1d2eba36-724b-11eb-1a38-a722db6ed12d
begin
	f_lo = solve(lo)
	f_mid = solve(mid)
	f_up = solve(up)
end;

# ╔═╡ a46d9e7a-724a-11eb-3bee-b7318707af35
begin
	xlim = (0, 150)
	plot( f_lo,  xlim=xlim, linewidth=2)
	plot!(f_mid, xlim=xlim, linewidth=2)
	plot!(f_up,  xlim=xlim, linewidth=2)
	plot!(D, func=cdf, xlim=xlim, legend=:topleft, markersize=1.5)
end

# ╔═╡ 873c4d70-7260-11eb-2143-eb7dcdd46986
f_up(100)[1]

# ╔═╡ 055dc8da-724f-11eb-3c4e-b105f4ad5535
f_lo.t[1], f_lo.t[end]

# ╔═╡ 03e664ee-724d-11eb-1ded-7ff577067591
function new_piecewise_cdf(α, g, k, γ, dist, probs=[0.01, 0.15, 0.85, 0.99])
	p = [α, g, k, γ]
	cutpoint = Float64[quantile(dist, probs)...]
	d = length(probs) - 1
	P = [ODEProblem(gsd!, [q[i]], (cutpoint[i], cutpoint[i+1]), p) for i in 1:d]
	S = [solve(x) for x in P]
	
	# Make a piecewise CDF
	F = function(x)
		x < cutpoint[1] && return max(S[1](x)[1], 0.0)
		x > cutpoint[end] && return min(S[end](x)[1], 1.0)
		idx = findfirst(cutpoint[1:end-1] .≤ x .≤ cutpoint[2:end])
		return S[idx](x)[1]
		idx
	end
	F
end

# ╔═╡ 6ac2bd84-724f-11eb-24ce-037a1203ff04
F = new_piecewise_cdf(p..., D)

# ╔═╡ 9e568be4-724f-11eb-3064-79064f1683f5
F(10) # value is less than all pieces. Return max(F₁(x), 0)

# ╔═╡ 77c9031c-724f-11eb-09a8-41a075c1baa9
F(40), cdf(D, 40) # first piece contains the value

# ╔═╡ 9393baba-724f-11eb-3f46-7f74e1e7359e
F(65), cdf(D, 65) # second piece contains the value

# ╔═╡ b29ace4e-724f-11eb-1404-f7a65deef37e
F(130), cdf(D, 130) # third piece contains value

# ╔═╡ c6b150ce-724f-11eb-35e3-8f8bc30a5b59
F(140), cdf(D, 140) # value is more than all pieces. Return min(Fₙ(x), 1)

# ╔═╡ Cell order:
# ╠═68a2a68a-7237-11eb-381a-2dea1a80b049
# ╟─734eebd6-723a-11eb-14eb-f9e995972c6a
# ╠═45fad45c-724d-11eb-19c3-39b2facb7eb5
# ╠═0c333696-723a-11eb-2278-2d121fe6007c
# ╠═85b212fc-723b-11eb-39e9-639cf2f426f7
# ╠═62112c32-724c-11eb-3c60-23f63b1c9c9c
# ╠═e2032e64-724b-11eb-39e8-b56ca11e737f
# ╠═370e4182-7260-11eb-25c1-b9c561abd7ec
# ╠═4f125984-7248-11eb-25f6-f11b5727c538
# ╠═1d2eba36-724b-11eb-1a38-a722db6ed12d
# ╠═a46d9e7a-724a-11eb-3bee-b7318707af35
# ╠═873c4d70-7260-11eb-2143-eb7dcdd46986
# ╠═055dc8da-724f-11eb-3c4e-b105f4ad5535
# ╠═03e664ee-724d-11eb-1ded-7ff577067591
# ╠═6ac2bd84-724f-11eb-24ce-037a1203ff04
# ╠═9e568be4-724f-11eb-3064-79064f1683f5
# ╠═77c9031c-724f-11eb-09a8-41a075c1baa9
# ╠═9393baba-724f-11eb-3f46-7f74e1e7359e
# ╠═b29ace4e-724f-11eb-1404-f7a65deef37e
# ╠═c6b150ce-724f-11eb-35e3-8f8bc30a5b59
