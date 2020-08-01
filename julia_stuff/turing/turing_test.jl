### A Pluto.jl notebook ###
# v0.11.2

using Markdown
using InteractiveUtils

# ╔═╡ 83fce932-d42c-11ea-3ceb-556bf1cc0cab


# ╔═╡ d4fc2446-d42b-11ea-0993-ed0c69c638cc


# ╔═╡ ed1a0036-d429-11ea-38f1-2bde892062b5
using Random, StatsPlots, Distributions

# ╔═╡ 5ef265f8-d42b-11ea-0d54-e5d1d8dfb73a
using Turing, MCMCChains

# ╔═╡ c7168726-d429-11ea-30ae-c5ce7773f6f5
pwd()

# ╔═╡ 9471efd4-d429-11ea-0a03-890a49b60bd9
import Pkg; Pkg.activate(".")

# ╔═╡ fadf78d6-d429-11ea-1706-2b68ac77f7d5
p_true = 0.5

# ╔═╡ 04c88e64-d42a-11ea-3881-453e2d951915
Ns = 0:100

# ╔═╡ 09231c84-d42a-11ea-1d61-bd8b598825f1
Random.seed!(12)

# ╔═╡ 1074e2e4-d42a-11ea-3741-0183ae696dec
data = rand(Bernoulli(p_true), last(Ns))

# ╔═╡ 1a371392-d42a-11ea-2c2a-b19eb6e081d8
prior_belief = Beta(2, 2)

# ╔═╡ 22a719aa-d42a-11ea-28a7-9b71e711b542
@gif for (i, N) in enumerate(Ns)
	heads = sum(data[1:i-1])
	tails = N - heads

	updated_belief = Beta(prior_belief.α + heads, prior_belief.β + tails)

	plot(updated_belief,
		title = "Updated belief after $(N) observations",
		xlabel = "probaility of heads",
		ylabel = "",
		legend = nothing,
		xlim = (0, 1),
		fill = 0,
		α = 0.3,
		w = 3)
	vline!([p_true])
end

# ╔═╡ a567b592-d42b-11ea-2205-755bc036c48a
@model coinflip(y) = begin
	p ~ Beta(1, 1)
	N = length(y)
	for n in 1:N
		y[n] ~ Bernoulli(p)
	end
end;

# ╔═╡ c4b05e1a-d42b-11ea-3667-9b32ca523eb8
begin
	iterations = 1000;
	ϵ = 0.05;
	τ = 10;
end

# ╔═╡ d791902e-d42b-11ea-2f29-a56dca5a8130
chain = sample(coinflip(data), HMC(ϵ, τ), iterations, progress=true)

# ╔═╡ eb4a2478-d42b-11ea-0094-bb175cd942a0
p_summary = chain[:p]

# ╔═╡ fc951c44-d42b-11ea-2457-19217e7c049f
plot(p_summary, seriestype=:histogram)

# ╔═╡ 069f025c-d42c-11ea-383d-61c13360340e
begin
	# Compute the posterior distribution in closed-form.
	N2 = length(data)
	heads2 = sum(data)
	updated_belief2 = Beta(prior_belief.α + heads2, prior_belief.β + N2 - heads2)
end

# ╔═╡ 805f63c0-d42c-11ea-08c8-7d9f35e16e18
begin
	# Visualize a blue density plot of the approximate posterior distribution using HMC (see Chain 1 in the legend).
	pl = plot(p_summary, seriestype = :density, xlim = (0,1), legend = :best, w = 2, c = :blue)

	# Visualize a green density plot of posterior distribution in closed-form.
	plot!(pl, range(0, stop = 1, length = 100), pdf.(Ref(updated_belief2), range(0, stop = 1, length = 100)), 
			xlabel = "probability of heads", ylabel = "", title = "", xlim = (0,1), label = "Closed-form",
			fill=0, α=0.3, w=3, c = :lightgreen)

	# Visualize the true probability of heads in red.
	vline!(pl, [p_true], label = "True probability", c = :red)
end

# ╔═╡ Cell order:
# ╟─c7168726-d429-11ea-30ae-c5ce7773f6f5
# ╠═9471efd4-d429-11ea-0a03-890a49b60bd9
# ╠═ed1a0036-d429-11ea-38f1-2bde892062b5
# ╟─fadf78d6-d429-11ea-1706-2b68ac77f7d5
# ╟─04c88e64-d42a-11ea-3881-453e2d951915
# ╠═09231c84-d42a-11ea-1d61-bd8b598825f1
# ╟─1074e2e4-d42a-11ea-3741-0183ae696dec
# ╟─1a371392-d42a-11ea-2c2a-b19eb6e081d8
# ╟─22a719aa-d42a-11ea-28a7-9b71e711b542
# ╠═5ef265f8-d42b-11ea-0d54-e5d1d8dfb73a
# ╠═a567b592-d42b-11ea-2205-755bc036c48a
# ╠═c4b05e1a-d42b-11ea-3667-9b32ca523eb8
# ╟─d791902e-d42b-11ea-2f29-a56dca5a8130
# ╟─eb4a2478-d42b-11ea-0094-bb175cd942a0
# ╟─fc951c44-d42b-11ea-2457-19217e7c049f
# ╟─069f025c-d42c-11ea-383d-61c13360340e
# ╟─805f63c0-d42c-11ea-08c8-7d9f35e16e18
# ╠═83fce932-d42c-11ea-3ceb-556bf1cc0cab
# ╠═d4fc2446-d42b-11ea-0993-ed0c69c638cc
