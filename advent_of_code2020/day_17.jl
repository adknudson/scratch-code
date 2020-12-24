### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 650202fa-45b4-11eb-0e98-5facb0b28da3
using OffsetArrays, PaddedViews

# ╔═╡ 1d80ebe8-4551-11eb-2fee-f92a32f00dbe
md"""# Day 17: Conway Cubes

As your flight slowly drifts through the sky, the Elves at the Mythical Information Bureau at the North Pole contact you. They'd like some help debugging a malfunctioning experimental energy source aboard one of their super-secret imaging satellites.

The experimental energy source is based on cutting-edge technology: a set of Conway Cubes contained in a pocket dimension! When you hear it's having problems, you can't help but agree to take a look.

The pocket dimension contains an infinite 3-dimensional grid. At every integer 3-dimensional coordinate (x,y,z), there exists a single cube which is either active or inactive.

In the initial state of the pocket dimension, almost all cubes start inactive. The only exception to this is a small flat region of cubes (your puzzle input); the cubes in this region start in the specified active (#) or inactive (.) state.

The energy source then proceeds to boot up by executing six cycles.

Each cube only ever considers its neighbors: any of the 26 other cubes where any of their coordinates differ by at most 1. For example, given the cube at `x=1,y=2,z=3`, its neighbors include the cube at `x=2,y=2,z=2`, the cube at `x=0,y=2,z=3`, and so on.

During a cycle, all cubes simultaneously change their state according to the following rules:

- If a cube is active and exactly 2 or 3 of its neighbors are also active, the cube remains active. Otherwise, the cube becomes inactive.
- If a cube is inactive but exactly 3 of its neighbors are active, the cube becomes active. Otherwise, the cube remains inactive.

The engineers responsible for this experimental energy source would like you to simulate the pocket dimension and determine what the configuration of cubes should be at the end of the six-cycle boot process.

For example, consider the following initial state:

```
.#.
..#
###
```

Even though the pocket dimension is 3-dimensional, this initial state represents a small 2-dimensional slice of it. (In particular, this initial state defines a 3x3x1 region of the 3-dimensional space.)

Simulating a few cycles from this initial state produces the following configurations, where the result of each cycle is shown layer-by-layer at each given z coordinate (and the frame of view follows the active cells in each cycle):

```
Before any cycles:

z=0
.#.
..#
###


After 1 cycle:

z=-1
#..
..#
.#.

z=0
#.#
.##
.#.

z=1
#..
..#
.#.


After 2 cycles:

z=-2
.....
.....
..#..
.....
.....

z=-1
..#..
.#..#
....#
.#...
.....

z=0
##...
##...
#....
....#
.###.

z=1
..#..
.#..#
....#
.#...
.....

z=2
.....
.....
..#..
.....
.....


After 3 cycles:

z=-2
.......
.......
..##...
..###..
.......
.......
.......

z=-1
..#....
...#...
#......
.....##
.#...#.
..#.#..
...#...

z=0
...#...
.......
#......
.......
.....##
.##.#..
...#...

z=1
..#....
...#...
#......
.....##
.#...#.
..#.#..
...#...

z=2
.......
.......
..##...
..###..
.......
.......
.......
```

After the full six-cycle boot process completes, 112 cubes are left in the active state.

Starting with your given initial configuration, simulate six cycles. How many cubes are left in the active state after the sixth cycle?
"""

# ╔═╡ ba977b84-45b7-11eb-089e-29d4cbe6ca95
const offset = [-1:1, -1:1, -1:1]

# ╔═╡ d9367bf6-45b4-11eb-3319-b1a358f7fd80
function parse_input(S, steps=6)
	x = hcat(collect.(readlines(S))...)
	x = permutedims(x)
	x = [p == '#' ? :Alive : :Dead for p in x]
	
	r, c = size(x)
	
	y = fill(:Dead, r+2steps, c+2steps, 1+2steps)
	y = OffsetArray(y, -steps, -steps, -steps-1)
	y[1:r, 1:c, 0] .= x
	y
end

# ╔═╡ 93e2a4e2-45b6-11eb-3f6c-fb15e942cbce
function neighbors(Cube, coord, offset)
	idx = Tuple(o .+ c for (c,o) in zip(coord, offset))
	PaddedView(:Dead, Cube, idx)
end

# ╔═╡ 94b39034-45bb-11eb-3231-4de348e00d6c
function Step(Cube, offset)
	Box = copy(Cube)
	for i in CartesianIndices(Cube)
		i_am = Cube[i]
		around_me = neighbors(Cube, Tuple(i), offset)
		number_alive = sum(==(:Alive), around_me)
		if i_am === :Alive && number_alive - 1 ∉ [2, 3]
			Box[i] = :Dead
		elseif i_am === :Dead && number_alive == 3
			Box[i] = :Alive
		end
	end
	Box
end

# ╔═╡ 23754a62-45ba-11eb-2d2a-47872253acc1
function Conway(S, offset, steps=6)
	Cube = parse_input(S, steps)
	for i in 1:steps
		Cube = Step(Cube, offset)
	end
	Cube
end

# ╔═╡ d839a04c-45bf-11eb-0741-9dd3f51d934b
game1 = Conway("day17_input.txt", offset);

# ╔═╡ fba49dca-45bf-11eb-0c06-b92d58e2a895
sum(==(:Alive), game1)

# ╔═╡ 196607ea-45c0-11eb-25d7-4b92b145dc36
md"""## Part Two

For some reason, your simulated results don't match what the experimental energy source engineers expected. Apparently, the pocket dimension actually has four spatial dimensions, not three.

The pocket dimension contains an infinite 4-dimensional grid. At every integer 4-dimensional coordinate (x,y,z,w), there exists a single cube (really, a hypercube) which is still either active or inactive.

Each cube only ever considers its neighbors: any of the 80 other cubes where any of their coordinates differ by at most 1. For example, given the cube at x=1,y=2,z=3,w=4, its neighbors include the cube at x=2,y=2,z=3,w=3, the cube at x=0,y=2,z=3,w=4, and so on.

The initial state of the pocket dimension still consists of a small flat region of cubes. Furthermore, the same rules for cycle updating still apply: during each cycle, consider the number of active neighbors of each cube.

For example, consider the same initial state as in the example above. Even though the pocket dimension is 4-dimensional, this initial state represents a small 2-dimensional slice of it. (In particular, this initial state defines a 3x3x1x1 region of the 4-dimensional space.)

Simulating a few cycles from this initial state produces the following configurations, where the result of each cycle is shown layer-by-layer at each given z and w coordinate:

```
Before any cycles:

z=0, w=0
.#.
..#
###


After 1 cycle:

z=-1, w=-1
#..
..#
.#.

z=0, w=-1
#..
..#
.#.

z=1, w=-1
#..
..#
.#.

z=-1, w=0
#..
..#
.#.

z=0, w=0
#.#
.##
.#.

z=1, w=0
#..
..#
.#.

z=-1, w=1
#..
..#
.#.

z=0, w=1
#..
..#
.#.

z=1, w=1
#..
..#
.#.


After 2 cycles:

z=-2, w=-2
.....
.....
..#..
.....
.....

z=-1, w=-2
.....
.....
.....
.....
.....

z=0, w=-2
###..
##.##
#...#
.#..#
.###.

z=1, w=-2
.....
.....
.....
.....
.....

z=2, w=-2
.....
.....
..#..
.....
.....

z=-2, w=-1
.....
.....
.....
.....
.....

z=-1, w=-1
.....
.....
.....
.....
.....

z=0, w=-1
.....
.....
.....
.....
.....

z=1, w=-1
.....
.....
.....
.....
.....

z=2, w=-1
.....
.....
.....
.....
.....

z=-2, w=0
###..
##.##
#...#
.#..#
.###.

z=-1, w=0
.....
.....
.....
.....
.....

z=0, w=0
.....
.....
.....
.....
.....

z=1, w=0
.....
.....
.....
.....
.....

z=2, w=0
###..
##.##
#...#
.#..#
.###.

z=-2, w=1
.....
.....
.....
.....
.....

z=-1, w=1
.....
.....
.....
.....
.....

z=0, w=1
.....
.....
.....
.....
.....

z=1, w=1
.....
.....
.....
.....
.....

z=2, w=1
.....
.....
.....
.....
.....

z=-2, w=2
.....
.....
..#..
.....
.....

z=-1, w=2
.....
.....
.....
.....
.....

z=0, w=2
###..
##.##
#...#
.#..#
.###.

z=1, w=2
.....
.....
.....
.....
.....

z=2, w=2
.....
.....
..#..
.....
.....
```

After the full six-cycle boot process completes, 848 cubes are left in the active state.

Starting with your given initial configuration, simulate six cycles in a 4-dimensional space. How many cubes are left in the active state after the sixth cycle?
"""

# ╔═╡ 162cbbfc-45c1-11eb-1897-df4ee7efbb45
const offset2 = [-1:1, -1:1, -1:1, -1:1]

# ╔═╡ 3b47ec88-45c1-11eb-1895-fd00bec2a19b
function parse_input2(S, steps=6)
	x = hcat(collect.(readlines(S))...)
	x = permutedims(x)
	x = [p == '#' ? :Alive : :Dead for p in x]
	
	r, c = size(x)
	
	y = fill(:Dead, r+2steps, c+2steps, 1+2steps, 1+2steps)
	y = OffsetArray(y, -steps, -steps, -steps-1, -steps-1)
	y[1:r, 1:c, 0, 0] .= x
	y
end

# ╔═╡ a331541a-45c1-11eb-2f09-f56e261c2225
function Conway2(S, offset, steps=6)
	Cube = parse_input2(S, steps)
	for i in 1:steps
		Cube = Step(Cube, offset)
	end
	Cube
end

# ╔═╡ b904f724-45c1-11eb-261e-7ddb3742b3d8
game2 = Conway2("day17_input.txt", offset2);

# ╔═╡ 943092cc-45c2-11eb-18e4-89b1e09ff7df
sum(==(:Alive), game2)

# ╔═╡ Cell order:
# ╟─1d80ebe8-4551-11eb-2fee-f92a32f00dbe
# ╠═650202fa-45b4-11eb-0e98-5facb0b28da3
# ╠═ba977b84-45b7-11eb-089e-29d4cbe6ca95
# ╠═d9367bf6-45b4-11eb-3319-b1a358f7fd80
# ╠═93e2a4e2-45b6-11eb-3f6c-fb15e942cbce
# ╠═94b39034-45bb-11eb-3231-4de348e00d6c
# ╠═23754a62-45ba-11eb-2d2a-47872253acc1
# ╠═d839a04c-45bf-11eb-0741-9dd3f51d934b
# ╠═fba49dca-45bf-11eb-0c06-b92d58e2a895
# ╟─196607ea-45c0-11eb-25d7-4b92b145dc36
# ╠═162cbbfc-45c1-11eb-1897-df4ee7efbb45
# ╠═3b47ec88-45c1-11eb-1895-fd00bec2a19b
# ╠═a331541a-45c1-11eb-2f09-f56e261c2225
# ╠═b904f724-45c1-11eb-261e-7ddb3742b3d8
# ╠═943092cc-45c2-11eb-18e4-89b1e09ff7df
