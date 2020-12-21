### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ fcda1e04-4349-11eb-0585-d189f7d0e7a9
md"""# Day 15: Rambunctious Recitation

You catch the airport shuttle and try to book a new flight to your vacation island. Due to the storm, all direct flights have been cancelled, but a route is available to get around the storm. You take it.

While you wait for your flight, you decide to check in with the Elves back at the North Pole. They're playing a memory game and are ever so excited to explain the rules!

In this game, the players take turns saying numbers. They begin by taking turns reading from a list of starting numbers (your puzzle input). Then, each turn consists of considering the most recently spoken number:

- If that was the first time the number has been spoken, the current player says 0.
- Otherwise, the number had been spoken before; the current player announces how many turns apart the number is from when it was previously spoken.

So, after the starting numbers, each turn results in that player speaking aloud either 0 (if the last number is new) or an age (if the last number is a repeat).

For example, suppose the starting numbers are 0,3,6:

- `Turn 1`: The 1st number spoken is a starting number, 0.
- `Turn 2`: The 2nd number spoken is a starting number, 3.
- `Turn 3`: The 3rd number spoken is a starting number, 6.
- `Turn 4`: Now, consider the last number spoken, 6. Since that was the first time the number had been spoken, the 4th number spoken is 0.
- `Turn 5`: Next, again consider the last number spoken, 0. Since it had been spoken before, the next number to speak is the difference between the turn number when it was last spoken (the previous turn, 4) and the turn number of the time it was most recently spoken before then (turn 1). Thus, the 5th number spoken is 4 - 1, 3.
- `Turn 6`: The last number spoken, 3 had also been spoken before, most recently on turns 5 and 2. So, the 6th number spoken is 5 - 2, 3.
- `Turn 7`: Since 3 was just spoken twice in a row, and the last two turns are 1 turn apart, the 7th number spoken is 1.
- `Turn 8`: Since 1 is new, the 8th number spoken is 0.
- `Turn 9`: 0 was last spoken on turns 8 and 4, so the 9th number spoken is the difference between them, 4.
- `Turn 10`: 4 is new, so the 10th number spoken is 0.

The sequence is `0,3,6,0,3,3,1,0,4,0`

(The game ends when the Elves get sick of playing or dinner is ready, whichever comes first.)

Their question for you is: what will be the 2020th number spoken? In the example above, the 2020th number spoken will be 436.

Here are a few more examples:

- Given the starting numbers `1,3,2`, the 2020th number spoken is `1`.
- Given the starting numbers `2,1,3`, the 2020th number spoken is `10`.
- Given the starting numbers `1,2,3`, the 2020th number spoken is `27`.
- Given the starting numbers `2,3,1`, the 2020th number spoken is `78`.
- Given the starting numbers `3,2,1`, the 2020th number spoken is `438`.
- Given the starting numbers `3,1,2`, the 2020th number spoken is `1836`.

Given your starting numbers, what will be the 2020th number spoken?

Your puzzle input is `19,20,14,0,9,1`.
"""

# ╔═╡ 33bbfbbc-4350-11eb-1ac3-69171f1e5728
function part1(input; N=2020)
	history = Vector{Int}()
	
	# Initialize game
	for i in input
		push!(history, i)
	end
	
	# Play rest of game
	for i in length(input)+1:N
		prev_num = last(history)
		last_occ = findlast(==(prev_num), history[1:end-1])
		n = last_occ === nothing ? i-1 : last_occ
		push!(history, i-1-n)
	end
	last(history), history
end

# ╔═╡ 6442c726-434a-11eb-1e66-8f736d70fa10
input = [19, 20, 14, 0, 9, 1]

# ╔═╡ 19a2e1c2-4351-11eb-319b-c7c41aacdc59
part1(input, N=2020)

# ╔═╡ 1c716aa6-4352-11eb-2cde-5f1ce7f1478b
md"""## Part Two

Impressed, the Elves issue you a challenge: determine the 30000000th number spoken. For example, given the same starting numbers as above:

- Given `0,3,6`, the `30000000`th number spoken is `175594`.
- Given `1,3,2`, the `30000000`th number spoken is `2578`.
- Given `2,1,3`, the `30000000`th number spoken is `3544142`.
- Given `1,2,3`, the `30000000`th number spoken is `261214`.
- Given `2,3,1`, the `30000000`th number spoken is `6895259`.
- Given `3,2,1`, the `30000000`th number spoken is `18`.
- Given `3,1,2`, the `30000000`th number spoken is `362`.

Given your starting numbers, what will be the 30000000th number spoken?
"""

# ╔═╡ 6ae146c2-4352-11eb-0361-8d97c4897872
function part2(input; N=2020)
	history  = Dict{Int, Int}() # number => last occurance
	n = length(input)

	# Initialize game
	for (i, v) in enumerate(input)
		history[v]  = i
	end

	# Play rest of game
	prev_num = last(input)
	for i in n+1:N
		
		# Find last occurance (ignoring last number)
		last_occ = get(history, prev_num, nothing)
		new_num = last_occ === nothing ? 0 : i-1-last_occ

		# Update last number history
		history[prev_num] = i-1
		
		prev_num = new_num
	end
	history[N] = prev_num
	history[N], history
end

# ╔═╡ 1b5043bc-4353-11eb-1a3b-170fb29a5f34
part2(input, N=30e6)

# ╔═╡ Cell order:
# ╟─fcda1e04-4349-11eb-0585-d189f7d0e7a9
# ╠═33bbfbbc-4350-11eb-1ac3-69171f1e5728
# ╠═6442c726-434a-11eb-1e66-8f736d70fa10
# ╠═19a2e1c2-4351-11eb-319b-c7c41aacdc59
# ╟─1c716aa6-4352-11eb-2cde-5f1ce7f1478b
# ╠═6ae146c2-4352-11eb-0361-8d97c4897872
# ╠═1b5043bc-4353-11eb-1a3b-170fb29a5f34
