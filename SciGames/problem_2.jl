### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 3099e3ec-9816-4437-851c-c8f85322a3f6
using StatsBase, IterTools

# ╔═╡ 4e113094-98ce-11eb-2cb7-17fff6cecb2a
md"""
# Problem 2 - Deck of 25

- 25 cards in a deck
  - 4 gold
  - 4 red
  - 4 purple
  - 4 blue
  - 4 green
  - 5 white
- player picks a card **without** replacement
- player draws until 3 white cards are picked
- player is awarded points based on the "picking values" table

**Example**

- if there are 3 gold cards, game pays 12
- if there are 4 blue cards, game pays 4
- if there are 3 gold and 4 blue cards, game pays 16

**Special Game**

- if game ends **after** all colored cards (not including white) are picked
  - player will be randomly awarded a value from the "clear all" column
- if game ends **before** all colored cards (not including white) are picked
  - player will be randomly awarded a value from the "white" column

**Question**

What is the average pay of this game?

## Start with Simulation
"""

# ╔═╡ e284bedc-84a3-48d8-aa72-8eac25773cc5
const deck = vcat(
	[:GOLD for _ in 1:4],
	[:RED for _ in 1:4],
	[:PURPLE for _ in 1:4],
	[:BLUE for _ in 1:4],
	[:GREEN for _ in 1:4],
	[:WHITE for _ in 1:5]
)

# ╔═╡ 116f78b4-1382-4c07-bff7-a93af22aa3fa
const colored_deck = vcat(
	[:GOLD for _ in 1:4],
	[:RED for _ in 1:4],
	[:PURPLE for _ in 1:4],
	[:BLUE for _ in 1:4],
	[:GREEN for _ in 1:4]
)

# ╔═╡ ca5f7990-92d9-45ee-908e-e443bccb8a51
const colored_deck_two_white = vcat(
	[:GOLD for _ in 1:4],
	[:RED for _ in 1:4],
	[:PURPLE for _ in 1:4],
	[:BLUE for _ in 1:4],
	[:GREEN for _ in 1:4],
	[:WHITE for _ in 1:2]
)

# ╔═╡ 90e36d38-1b97-4cbd-8f1d-5bb52c19bc8b
const payout_table = Dict(
	:GOLD => (12, 24),
	:RED => (6, 12),
	:PURPLE => (4, 8),
	:BLUE => (2, 4),
	:GREEN => (1, 2)
)

# ╔═╡ ef4911bf-e962-40f2-b170-9e6dd2c0106a
function draw!(d)
	idx = rand(1:length(d))
	val = d[idx]
	deleteat!(d, idx)
	return val
end

# ╔═╡ 302f9585-d243-48ef-9a51-39e0165bc45a
function play_game!(d)
	seq = Vector{Symbol}()
	while !isempty(d) && count(==(:WHITE), seq) < 3
		push!(seq, draw!(d))
	end
	return seq
end

# ╔═╡ f46c3ae1-7d49-4330-ab2d-d0623f9b94b7
function evaluate_game(game, pay)
	d = countmap(game)
	# Get just winning cards
	filter!(v -> v.second > 2, d)
	# Get just the colored cards
	filter!(k -> k.first != :WHITE, d)
	
	# Calculate payout
	simple_pay = 0
	if !isempty(d)
		for (k,v) in d
			# branchless addition ;)
			simple_pay += (v==3)*first(pay[k]) + (v==4)*last(pay[k])
		end
	end
	
	# Check if all cleared
	all_cleared = sum(values(d)) == 20
	special_pay = all_cleared ? rand([50, 30, 20]) : rand([10, 3, 2])
	total_pay = simple_pay + special_pay
	
	return d, simple_pay, special_pay, total_pay
end

# ╔═╡ b5c06c3f-af9a-4d6a-bb8c-4bfa457b11d6
function my_sim(deck, pay, n)
	[last(evaluate_game(play_game!(copy(deck)), payout_table)) for _ in 1:n]
end

# ╔═╡ 83997828-0e58-4cbb-bb76-d81ec7d6cdb0
X = my_sim(deck, payout_table, 1_000_000);

# ╔═╡ b3c318bd-3326-4360-9873-ccc6c076c083
mean(X)

# ╔═╡ 23ab46fe-bce2-4ddb-b976-f42d87c38c10
md"""
## Theoretical Results

Perhapse this represents a multinomial distribution? Valid combinations consist of all possibilities where there are three white cards, and the last card drawn **must** be white. Is it possible to enumerate all possibilities and calculate the payouts and probability.

I'll need to break out my combinatorics book.

The possible sequences are 

$$x_1, x_2, \ldots, x_i, \ldots, x_j, \ldots, x_{n-1}, x_n$$

where $x_i$, $x_j$, and $x_n$ are white.

The expected value of a game can be written as

$$E(\textrm{game}) = E(\textrm{game} | \textrm{all clear})\cdot P(\textrm{all clear}) + E(\textrm{game} | \textrm{not all clear})\cdot P(\textrm{not all clear})$$

The probability of clearing all the cards is given by a hypergeometric distribution where there are exactly two white cards drawn in a total of 22 draws from a deck of 25, where 5 of the cards are white. The 23rd draw is guaranteed to be the third white card that ends the game. The probability of this event comes out to $\frac{1}{230}$.

The expected value of a game *given* that it is all cleared is the picking values (50) plus the expected value of the random clear all award, which is $\frac{100}{3}$.

$$E(\textrm{game} | \textrm{all clear}) = \frac{250}{3}$$

So now we have

$$E(\textrm{game}) = \frac{250}{3} \cdot \frac{1}{230} + E(\textrm{game} | \textrm{not all clear})\cdot \frac{229}{230}$$

The difficult part is now in determining the expected value of a game given that not all colored cards were cleared.
"""

# ╔═╡ 5c52ffba-b71f-4357-93da-9431abfde8cc
g1, p1 = 250//3, 1//230

# ╔═╡ c2ecb5f8-5543-4b0e-b27c-d16e4853e4bd
md"""
### Expectected value of a game given not all clear

- a game can be a sequence of length $\{3, 4, \ldots, 22\}$
- a sequence of length $n$ with $\{k_1, \ldots, k_i\}$ colored cards is more or less indistinguishable from other sequences of length $n$ with the same counts but different lables
  - the only distinguishing factor is the payout

Multivariate hypergeometric distribution?

$$P(\textrm{a gold, b red, c purple, d blue, e green, 2 white}) = \frac{{4 \choose a} {4 \choose b} {4 \choose c} {4 \choose d} {4 \choose e} {5 \choose 2}}{25 \choose k}$$


"""

# ╔═╡ 8a2a3109-5297-44d4-84c5-5aa7611bdb10
function mult_hypergeom(Ks, ks)
	N = sum(Ks)
	n = sum(ks)
	numerator = prod(binomial(n, k) for (n,k) in zip(Ks, ks))
	denominator = binomial(N, n)
	numerator / denominator
end

# ╔═╡ 52669ca1-8a0c-4b99-ae13-ebb1b2e461e4
function hand_value(game, pay)
	d = countmap(game)
	# Get just winning cards
	filter!(v -> v.second > 2, d)
	# Get just the colored cards
	filter!(k -> k.first != :WHITE, d)
	
	# Calculate payout
	simple_pay = 0
	if !isempty(d)
		for (k,v) in d
			# branchless addition ;)
			simple_pay += (v==3)*first(pay[k]) + (v==4)*last(pay[k])
		end
	end
	
	return simple_pay
end

# ╔═╡ d6371d77-8c0e-462d-932d-547eeb4257ea
function calc_expected()
	s = 0.0
	pr = 0.0
	for K in 0:20
		P = unique(collect(subsets(colored_deck, Val{K}())))
		for p in P
			if isempty(p)
				# no colored cards and two white cards
				k = [0, 0, 0, 0, 0, 2]
			else
				# get counts of cards
				d = countmap(p)
				k = collect(values(d))
				
				# add zeros for non-drawn cards
				# add two white cards
				k = vcat(k, zeros(Int, 5-length(k)), 2)
			end
			
			prob_of_sequence = mult_hypergeom([4, 4, 4, 4, 4, 5], k)
			prob_last_white = (3 / (25 - K - 2))
			prob = prob_of_sequence * prob_last_white
			
			val = isempty(p) ? 0 : hand_value(p, payout_table)
			
			s += K == 20 ? prob * (val + 100/3) : prob * (val + 5)
			pr += prob
		end
	end
	s, pr
end

# ╔═╡ 385abb3a-808b-49e4-b9bd-a5765c0086ed
g2, total_prob = calc_expected()

# ╔═╡ c28d34ba-0506-4f8a-b168-f3650cc26f69
md"""
## Answer

At some point I realized that I don't need to break up the expected value computation, and I can use a conditional to add the expected value of the special payout (all cleared vs not). This let's me consider all combination of games and get their probabilities.

**Answer:** The expected value of a game is $(round(g2, digits=4)), which matches the simulated results.
"""

# ╔═╡ Cell order:
# ╠═3099e3ec-9816-4437-851c-c8f85322a3f6
# ╟─4e113094-98ce-11eb-2cb7-17fff6cecb2a
# ╠═e284bedc-84a3-48d8-aa72-8eac25773cc5
# ╠═116f78b4-1382-4c07-bff7-a93af22aa3fa
# ╠═ca5f7990-92d9-45ee-908e-e443bccb8a51
# ╠═90e36d38-1b97-4cbd-8f1d-5bb52c19bc8b
# ╠═ef4911bf-e962-40f2-b170-9e6dd2c0106a
# ╠═302f9585-d243-48ef-9a51-39e0165bc45a
# ╠═f46c3ae1-7d49-4330-ab2d-d0623f9b94b7
# ╠═b5c06c3f-af9a-4d6a-bb8c-4bfa457b11d6
# ╠═83997828-0e58-4cbb-bb76-d81ec7d6cdb0
# ╠═b3c318bd-3326-4360-9873-ccc6c076c083
# ╟─23ab46fe-bce2-4ddb-b976-f42d87c38c10
# ╠═5c52ffba-b71f-4357-93da-9431abfde8cc
# ╟─c2ecb5f8-5543-4b0e-b27c-d16e4853e4bd
# ╠═8a2a3109-5297-44d4-84c5-5aa7611bdb10
# ╠═52669ca1-8a0c-4b99-ae13-ebb1b2e461e4
# ╠═d6371d77-8c0e-462d-932d-547eeb4257ea
# ╠═385abb3a-808b-49e4-b9bd-a5765c0086ed
# ╟─c28d34ba-0506-4f8a-b168-f3650cc26f69
