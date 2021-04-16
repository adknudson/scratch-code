### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 005e7f76-98ad-11eb-18e1-cb952386c98b
using LinearAlgebra, SparseArrays, IterTools, Match

# ╔═╡ 08333558-34ac-438b-88dc-34073d7df58f
using QuantEcon

# ╔═╡ 141eaf94-bbb3-4d28-8921-caf255dcb03b
md"""
# Problem One - 15 Independent Reels

- 15 independent reels
- each reel has two symbols: scatter and blank
- P(scatter) = 0.2
- the player starts with 3 free spins
- each time one or more reels lands on scatter, the number of spins resets to 3
- the game ends when all 15 rells show scatter or player runs out of spins
- for each locked scatter, the player is awarded credits

**Questions:**

- What is the average pay?
- What is the average number of scatters?
- What is the average number of spins?

## Expected payout of landing on one scatter

Once a reel lands on a scatter symbol, a player is awarded some number of credits. The tables are chosen at random, and the credit from each table is also random (each with their respective weights). Then the expected value can be found by simply multiplying the value by the probability and summing.
"""

# ╔═╡ a1be6aef-fdb2-4a09-b4ed-d9f3e9add925
begin
	struct Table
		credits
		weights
		probs
	end
	Table(crd, wgt) = Table(crd, wgt, wgt .// sum(wgt))
	weights(T::Table) = T.weights
	probs(T::Table) = T.probs
	credits(T::Table) = T.credits
end

# ╔═╡ 4455a61c-e69a-48e9-8c4c-49823519a920
# Define each of the credit tables
begin
	T1 = Table([1,2,3], [20, 20, 10])
	T2 = Table([4,5,8], [20, 15, 10])
	T3 = Table([10, 12, 15], [20, 10, 10])
	Credit_Table = Table(nothing, [1_000_000, 185_000, 105_000])
end

# ╔═╡ 1a38862d-64f1-4b30-850c-35bc21a30f9e
expected_payout = [credits(T) .* probs(T) for T in [T1, T2, T3]] |>
	T -> [t .* p for (t,p) in zip(T, probs(Credit_Table))] |>
	sum |> 
    sum

# ╔═╡ 49f8c028-2322-40dc-916e-16638162f76b
md"""
The expected payout of a single reel is $(round(Float64(expected_payout), digits=4)) credits.
"""

# ╔═╡ 148b143f-6c6f-42a8-9231-4c56b89f5a7f
md"""
## Representing the game as a Markov chain

Let $N_t$ be the number of scatter symbols showing after $t$ spins, and $S_t$ be the number of remaining spins after $t$ spins. Also let $X_t$ be the tuple of scatter-spins that represents the state of the game after $t$ spins. E.g. $X_0 = (0, 3)$ is the starting state of the game (0 scatters and 3 remaining spins).

Notice that a transition to the next state depends only on the current state, thus the game can be represented as a Markov chain. The one-step transition probability is denoted by

$$P_{ij}^{t, t+1} = P(X_{t+1} = (N_j, S_j) \vert X_t = (N_i, S_i)$$

There are multiple absorbing states in the model, namely when the number of remaining spins reaches zero ($X_t = (N_t, 0)$) or when the number of scatter symbols reaches 15 ($X_t = (15, 3)$).

After a spin, the number of scatter symbols increases and the spin counter resets to 3, or the number of scatter symbols remains the same and the spin counter decrements by one.

$$\textrm{If } X_t = (N_t, S_t)\textrm{ then }X_{t+1} = \begin{cases}
	(N_{t+1}, 3) & \textrm{where } N_t < N_{t+1} \le 15 \\
	(N_t, S_t - 1) & 
\end{cases}$$


"""

# ╔═╡ 771c65a5-820e-480a-b608-64181a92908f
# Basic mathematical variables
begin
	p = 0.2
	q = 1 - p
	Nₜ = 0:1:14
	Sₜ = 0:1:3
	states = collect(IterTools.product(Nₜ,Sₜ)) |> vec
	push!(states, (15,3))
	# this ordering makes sense in my head. Spins decrease and scatters increase
	sort!(states, by = x -> (x[1], -x[2]))
	d = length(states)
end;

# ╔═╡ 0e62467b-de4e-4f79-bb94-e7484622892d
states

# ╔═╡ e7d25c82-0065-438f-9672-ed81f57a2295
# Create an empty transition probability matrix
P = spzeros(Float64, d, d);

# ╔═╡ ecd5a8a8-7628-40f0-94c4-84b569648b9e
# Helpful function for binomial experiments
binomial_pmf(n, k, p) = binomial(n, k) * p^k * (1-p)^(n-k)

# ╔═╡ c78d53bc-714b-44fc-a76c-51c10ae6c96e
# Fill in the transition matrix
for (ti, i) in enumerate(states)
	for (tj, j) in enumerate(states)
		P[ti, tj] = @match (i, j) begin
			# winning game
			((15, 3),  (15, 3)) => 1.0
			# out of spins
			((Nᵢ, 0),  (Nⱼ, 0)), if Nᵢ == Nⱼ end => 1.0
			# no scatters in Nᵢ reels
			((Nᵢ, Sᵢ), (Nⱼ, Sⱼ)), if Sᵢ == Sⱼ+1 && Nᵢ == Nⱼ end => q^(15-Nᵢ)
			# at least one scatter reel
			((Nᵢ, Sᵢ), (Nⱼ, 3)), if Sᵢ ≠ 0 && Nⱼ > Nᵢ end => binomial_pmf(15-Nᵢ, Nⱼ-Nᵢ, p)
			_ => 0.0
		end
	end
end

# ╔═╡ 9dbf2b99-3112-4735-a27c-97a24f6bb82e
# ensure sparsity for computational efficiency
dropzeros!(P);

# ╔═╡ 2bc593c9-893c-4d3b-bda5-e8b6b3fd2550
md"""
### Using properties of an absorbing Markov chain

[Absorbing Markov chain reference - Wikipedia](https://en.wikipedia.org/wiki/Absorbing_Markov_chain)

The locations and values used to populate the transition matrix were determined with some pen and paper scratch. Essentially each spin can be represented as a binomial random experiment, and the transition probabilities are filled as such.

With the transition matrix, $P$, we can put it into the canonical form in order to calculate convenient properties of an absorbing Markov chain. We put it into the canonical form by finding the absorbing states, and re-ordering $P$.
"""

# ╔═╡ e3063de8-bfab-4004-9172-a0f8d0f7acb1
# find the absorbing states
begin
	absorbing_states = vec(collect(mapslices(r -> any(r .== 1.0), P, dims=2)))
	state_order = vcat(findall(.!absorbing_states), findall(absorbing_states))
	state_reord = states[state_order]
end;

# ╔═╡ b9fa55d1-4088-4aa0-800a-1f56995c9294


# ╔═╡ 4ec1e399-1d2b-44c0-9a5a-c90dd4d20170
# Put the transition matrix in canonical form
begin
	A = P[absorbing_states, absorbing_states]
	R = P[.!absorbing_states, absorbing_states]
	Q = P[.!absorbing_states, .!absorbing_states]
	Z = P[absorbing_states, .!absorbing_states]
	C = [
		Q R
		Z A
	]
	dropzeros!(C)
end

# ╔═╡ 7573784c-7772-4a49-9b77-a9601090b6b3
md"""
### Computing the fundamental matrix

The expected number of times the chain is in state $j$, given that the chain started in state $i$.
"""

# ╔═╡ a735b6c0-3477-425e-a9e0-010f5f10dcd2
# Fundamental matrix
N = inv(Matrix(I - Q))

# ╔═╡ 2b026b7b-2184-458d-9da9-1c0d9cfe8541
md"""
# Answering the questions

## Question 1 - Average Pay

The expected pay is the expected number of scatters times the expected payout of one reel. As determined earlier, the expected payout of a single reel is $(round(Float64(expected_payout), digits=4)) credits. The expected number of scatters starting from (0, 3) is found by finding the absorbtion probabilities and multiplying by their respective number of scatters. The expected number of scatters is answered in question 2, so see below for how that number is achieved.
"""

# ╔═╡ 544729ed-399a-448b-a3cd-e0d2e1118da9
md"""
## Question 2 - Average number of scatters

*What are the absorbing probabilities*
"""

# ╔═╡ 06366a39-6d39-4b93-8ca8-f541507b330b
# Absorbing probabilities
B = N * R

# ╔═╡ 0307ffeb-c206-4dab-912c-e2caaefede5c
# long run probability P(X∞=j | X₀=(0,3))
B1 = B[1,:]

# ╔═╡ a5201364-0629-4f12-a8e9-ca45cdee7a52
expected_num_scatters = sum(B1 .* first.(states[absorbing_states]))

# ╔═╡ 86916a3c-cf0b-470e-b698-eb7c80cff680
expected_total_pay = expected_num_scatters * expected_payout

# ╔═╡ 8b2f3eaa-ef88-49ee-9efb-ca5243011ba6
md"""
**Answer:** The expected total credits is $(round(expected_total_pay, digits = 4))
"""

# ╔═╡ 7894d71d-fa20-4190-b77d-08d16fd75fa5
md"""
**Answer:** The expected number of scatters is $(round(expected_num_scatters, digits = 4))
"""

# ╔═╡ 89f86495-1ea9-40b4-aa3b-7315a1dc7e46
md"""
## Question 3 - Average number of spins

*What is the expected number of steps before being absorbed*
"""

# ╔═╡ 4cd392a3-60df-4fc5-b3f9-eec1cfd9f735
# E[steps] = N⋅1
expected_num_steps = N * ones(size(N,2), 1)

# ╔═╡ 2001ad25-0d34-4174-b743-347402129e32
# E[num steps] starting from X₀=(0,3)
expected_num_steps[1]

# ╔═╡ 26f05a44-bd1a-4a42-86b9-ea02795e97f2
md"""
**Answer:** The expected number of spins is $(round(expected_num_steps[1], digits = 4))
"""

# ╔═╡ 58cdf323-1fd4-4e1d-8465-22a0c83dc6f0
md"""
# Simulation Study

*Trust but verify*
"""

# ╔═╡ 82f65b58-38eb-4eaa-92da-35546f3ec022
M = MarkovChain(P, states)

# ╔═╡ 6d655680-bda8-47a2-8c2c-3717ababcb16
function my_sim(M::MarkovChain)
	X = simulate(M, 45, init = 1)
	X = unique(X)
	return (scatters = first(last(X)), spins = length(X) - 1)
end

# ╔═╡ b5edfae5-7fb2-4097-9eb1-c92fe5903d5b
X = [my_sim(M) for _ in 1:10_000_000];

# ╔═╡ fefb5f0a-a98b-444a-ad5a-6bbc11c5125c
# Expected number of scatters
mean(first.(X))

# ╔═╡ 781838cc-70ac-4b3f-aeb0-e36b11ddbc27
# Expected number of spins
mean(last.(X))

# ╔═╡ Cell order:
# ╠═005e7f76-98ad-11eb-18e1-cb952386c98b
# ╠═08333558-34ac-438b-88dc-34073d7df58f
# ╟─141eaf94-bbb3-4d28-8921-caf255dcb03b
# ╠═a1be6aef-fdb2-4a09-b4ed-d9f3e9add925
# ╠═4455a61c-e69a-48e9-8c4c-49823519a920
# ╠═1a38862d-64f1-4b30-850c-35bc21a30f9e
# ╟─49f8c028-2322-40dc-916e-16638162f76b
# ╟─148b143f-6c6f-42a8-9231-4c56b89f5a7f
# ╠═771c65a5-820e-480a-b608-64181a92908f
# ╠═0e62467b-de4e-4f79-bb94-e7484622892d
# ╠═e7d25c82-0065-438f-9672-ed81f57a2295
# ╠═ecd5a8a8-7628-40f0-94c4-84b569648b9e
# ╠═c78d53bc-714b-44fc-a76c-51c10ae6c96e
# ╠═9dbf2b99-3112-4735-a27c-97a24f6bb82e
# ╟─2bc593c9-893c-4d3b-bda5-e8b6b3fd2550
# ╠═e3063de8-bfab-4004-9172-a0f8d0f7acb1
# ╠═b9fa55d1-4088-4aa0-800a-1f56995c9294
# ╠═4ec1e399-1d2b-44c0-9a5a-c90dd4d20170
# ╟─7573784c-7772-4a49-9b77-a9601090b6b3
# ╠═a735b6c0-3477-425e-a9e0-010f5f10dcd2
# ╟─2b026b7b-2184-458d-9da9-1c0d9cfe8541
# ╠═86916a3c-cf0b-470e-b698-eb7c80cff680
# ╟─8b2f3eaa-ef88-49ee-9efb-ca5243011ba6
# ╟─544729ed-399a-448b-a3cd-e0d2e1118da9
# ╠═06366a39-6d39-4b93-8ca8-f541507b330b
# ╠═0307ffeb-c206-4dab-912c-e2caaefede5c
# ╠═a5201364-0629-4f12-a8e9-ca45cdee7a52
# ╟─7894d71d-fa20-4190-b77d-08d16fd75fa5
# ╟─89f86495-1ea9-40b4-aa3b-7315a1dc7e46
# ╠═4cd392a3-60df-4fc5-b3f9-eec1cfd9f735
# ╠═2001ad25-0d34-4174-b743-347402129e32
# ╟─26f05a44-bd1a-4a42-86b9-ea02795e97f2
# ╟─58cdf323-1fd4-4e1d-8465-22a0c83dc6f0
# ╠═82f65b58-38eb-4eaa-92da-35546f3ec022
# ╠═6d655680-bda8-47a2-8c2c-3717ababcb16
# ╠═b5edfae5-7fb2-4097-9eb1-c92fe5903d5b
# ╠═fefb5f0a-a98b-444a-ad5a-6bbc11c5125c
# ╠═781838cc-70ac-4b3f-aeb0-e36b11ddbc27
