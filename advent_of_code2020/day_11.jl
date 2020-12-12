### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ 43c28914-3c33-11eb-29b6-f1aa2446b99e
using OffsetArrays

# ╔═╡ 9cc92e7e-3caa-11eb-3d16-e37acdb65ad1
using LinearAlgebra, IterTools

# ╔═╡ 6b125d46-3b7f-11eb-03fc-8927c2b584a4
md"""
# Day 11: Seating System

Your plane lands with plenty of time to spare. The final leg of your journey is a ferry that goes directly to the tropical island where you can finally start your vacation. As you reach the waiting area to board the ferry, you realize you're so early, nobody else has even arrived yet!

By modeling the process people use to choose (or abandon) their seat in the waiting area, you're pretty sure you can predict the best place to sit. You make a quick map of the seat layout (your puzzle input).

The seat layout fits neatly on a grid. Each position is either floor (.), an empty seat (L), or an occupied seat (#). For example, the initial seat layout might look like this:

```
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
```

Now, you just need to model the people who will be arriving shortly. Fortunately, people are entirely predictable and always follow a simple set of rules. All decisions are based on the number of occupied seats adjacent to a given seat (one of the eight positions immediately up, down, left, right, or diagonal from the seat). The following rules are applied to every seat simultaneously:

If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
Otherwise, the seat's state does not change.
Floor (.) never changes; seats don't move, and nobody sits on the floor.

After one round of these rules, every seat in the example layout becomes occupied:

```
#.##.##.##
#######.##
#.#.#..#..
####.##.##
#.##.##.##
#.#####.##
..#.#.....
##########
#.######.#
#.#####.##
```

After a second round, the seats with four or more occupied adjacent seats become empty again:

```
#.LL.L#.##
#LLLLLL.L#
L.L.L..L..
#LLL.LL.L#
#.LL.LL.LL
#.LLLL#.##
..L.L.....
#LLLLLLLL#
#.LLLLLL.L
#.#LLLL.##
```

This process continues for three more rounds:

```
#.##.L#.##
#L###LL.L#
L.#.#..#..
#L##.##.L#
#.##.LL.LL
#.###L#.##
..#.#.....
#L######L#
#.LL###L.L
#.#L###.##
```

```
#.#L.L#.##
#LLL#LL.L#
L.L.L..#..
#LLL.##.L#
#.LL.LL.LL
#.LL#L#.##
..L.L.....
#L#LLLL#L#
#.LLLLLL.L
#.#L#L#.##
```

```
#.#L.L#.##
#LLL#LL.L#
L.#.L..#..
#L##.##.L#
#.#L.LL.LL
#.#L#L#.##
..L.L.....
#L#L##L#L#
#.LLLLLL.L
#.#L#L#.##
```

At this point, something interesting happens: the chaos stabilizes and further applications of these rules cause no seats to change state! Once people stop moving around, you count 37 occupied seats.

Simulate your seating area by applying the seating rules repeatedly until no seats change state. How many seats end up occupied?
"""

# ╔═╡ 573fc72a-3bf9-11eb-3a87-3f2aafcc3659
function parse_input(str)
	read_tile(c) = c == 'L' ? :empty : c == '#' ? :occupied : :floor
	x = collect.(readlines(str))
	x = hcat([read_tile.(r) for r in x]...) |> 
		permutedims
	N, M = size(x)
	let y = OffsetMatrix(fill(:floor, size(x) .+ 2), 0:N+1, 0:M+1)
		y[1:N, 1:M] .= x
		y
	end
end

# ╔═╡ 7dd72eca-3c33-11eb-0b27-67de8e415fd5
function predict_seating(layout)
	current_layout = copy(layout)
	counter = 0
	S = Inf
	N, M = size(layout) .- 2
	while S > 0
		counter += 1
		S = 0
		next_layout = copy(current_layout)
		for i = 1:N, j=1:M
			adjacent = current_layout[i-1:i+1, j-1:j+1]
			n_occupied = sum(==(:occupied), adjacent)
			if current_layout[i,j] == :floor
				continue
			elseif current_layout[i,j] == :occupied
				if n_occupied ≥ 5
					next_layout[i,j] = :empty
					S += 1
				end
			else
				if n_occupied == 0
					next_layout[i,j] = :occupied
					S += 1
				end
			end
		end
		current_layout = copy(next_layout)
	end
	(counter, current_layout)
end			

# ╔═╡ db5e791e-3bfb-11eb-3027-a59f8ba4feea
layout = parse_input("day11_input.txt")

# ╔═╡ 4d7c2424-3c35-11eb-0e81-0fd98b5c4bd9
n, steady_state = predict_seating(layout)

# ╔═╡ 3d5ece04-3c36-11eb-0250-67b911ca1bc7
sum(==(:occupied), steady_state)

# ╔═╡ 2842501e-3c3a-11eb-1ab1-f7fb6c926108
md"""
## Part Two

As soon as people start to arrive, you realize your mistake. People don't just care about adjacent seats - they care about the first seat they can see in each of those eight directions!

Now, instead of considering just the eight immediately adjacent seats, consider the first seat in each of those eight directions. For example, the empty seat below would see eight occupied seats:

```
.......#.
...#.....
.#.......
.........
..#L....#
....#....
.........
#........
...#.....
```

The leftmost empty seat below would only see one empty seat, but cannot see any of the occupied ones:

```
.............
.L.L.#.#.#.#.
.............
```

The empty seat below would see no occupied seats:

```
.##.##.
#.#.#.#
##...##
...L...
##...##
#.#.#.#
.##.##.
```

Also, people seem to be more tolerant than you expected: it now takes five or more visible occupied seats for an occupied seat to become empty (rather than four or more from the previous rules). The other rules still apply: empty seats that see no occupied seats become occupied, seats matching no rule don't change, and floor never changes.

Given the same starting layout as above, these new rules cause the seating area to shift around as follows:

```
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
```

```
#.##.##.##
#######.##
#.#.#..#..
####.##.##
#.##.##.##
#.#####.##
..#.#.....
##########
#.######.#
#.#####.##
```

```
#.LL.LL.L#
#LLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLL#
#.LLLLLL.L
#.LLLLL.L#
```

```
#.L#.##.L#
#L#####.LL
L.#.#..#..
##L#.##.##
#.##.#L.##
#.#####.#L
..#.#.....
LLL####LL#
#.L#####.L
#.L####.L#
```

```
#.L#.L#.L#
#LLLLLL.LL
L.L.L..#..
##LL.LL.L#
L.LL.LL.L#
#.LLLLL.LL
..L.L.....
LLLLLLLLL#
#.LLLLL#.L
#.L#LL#.L#
```

```
#.L#.L#.L#
#LLLLLL.LL
L.L.L..#..
##L#.#L.L#
L.L#.#L.L#
#.L####.LL
..#.#.....
LLL###LLL#
#.LLLLL#.L
#.L#LL#.L#
```

```
#.L#.L#.L#
#LLLLLL.LL
L.L.L..#..
##L#.#L.L#
L.L#.LL.L#
#.LLLL#.LL
..#.L.....
LLL###LLL#
#.LLLLL#.L
#.L#LL#.L#
```

Again, at this point, people stop shifting around and the seating area reaches equilibrium. Once this occurs, you count 26 occupied seats.

Given the new visibility method and the rule change for occupied seats becoming empty, once equilibrium is reached, how many seats end up occupied?
"""

# ╔═╡ bc15ef10-3caa-11eb-327a-cff9f54e44c9
function check_one_direction(layout, i, j, dy, dx)
	N, M = size(layout) .- 2
	dy == 0 && dx == 0 && return 0
	while 1 ≤ i ≤ N && 1 ≤ j ≤ M
		i += dy
		j += dx
		layout[i,j] == :occupied && return 1
		layout[i,j] == :empty && return 0
	end
	return 0
end

# ╔═╡ a8622172-3cab-11eb-2b21-0bc79dc003c8
function check_all_directions(layout, i, j)
	dirs = product([-1, 0, 1], [-1, 0, 1])
	sum(check_one_direction(layout, i, j, d[1], d[2]) for d in dirs)
end

# ╔═╡ 86940a7e-3cab-11eb-1236-953275d03df3
function predict_seating2(layout; MAXIT=10)
	current_layout = copy(layout)
	counter = 0
	S = Inf
	N, M = size(layout) .- 2
	while S > 0 && counter < MAXIT
		counter += 1
		S = 0
		next_layout = copy(current_layout)
		for i = 1:N, j=1:M
			n_occupied = check_all_directions(current_layout, i, j)
			if current_layout[i,j] == :floor
				continue
			elseif current_layout[i,j] == :occupied
				if n_occupied ≥ 5
					next_layout[i,j] = :empty
					S += 1
				end
			else
				if n_occupied == 0
					next_layout[i,j] = :occupied
					S += 1
				end
			end
		end
		current_layout = copy(next_layout)
	end
	(counter, current_layout)
end

# ╔═╡ b8d59cf6-3caf-11eb-0cb8-25ecf220e24e
n2, steady_state2 = predict_seating2(layout, MAXIT=100)

# ╔═╡ c971b3c4-3caf-11eb-2ecc-41d25b47e8a7
sum(==(:occupied), steady_state2)

# ╔═╡ Cell order:
# ╟─6b125d46-3b7f-11eb-03fc-8927c2b584a4
# ╠═43c28914-3c33-11eb-29b6-f1aa2446b99e
# ╠═573fc72a-3bf9-11eb-3a87-3f2aafcc3659
# ╠═7dd72eca-3c33-11eb-0b27-67de8e415fd5
# ╠═db5e791e-3bfb-11eb-3027-a59f8ba4feea
# ╠═4d7c2424-3c35-11eb-0e81-0fd98b5c4bd9
# ╠═3d5ece04-3c36-11eb-0250-67b911ca1bc7
# ╟─2842501e-3c3a-11eb-1ab1-f7fb6c926108
# ╠═9cc92e7e-3caa-11eb-3d16-e37acdb65ad1
# ╠═bc15ef10-3caa-11eb-327a-cff9f54e44c9
# ╠═a8622172-3cab-11eb-2b21-0bc79dc003c8
# ╠═86940a7e-3cab-11eb-1236-953275d03df3
# ╠═b8d59cf6-3caf-11eb-0cb8-25ecf220e24e
# ╠═c971b3c4-3caf-11eb-2ecc-41d25b47e8a7
