### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ 8548f580-3cb0-11eb-3f74-c5c0d6bddb6d
md"""
# Day 12: Rain Risk

Your ferry made decent progress toward the island, but the storm came in faster than anyone expected. The ferry needs to take evasive actions!

Unfortunately, the ship's navigation computer seems to be malfunctioning; rather than giving a route directly to safety, it produced extremely circuitous instructions. When the captain uses the PA system to ask if anyone can help, you quickly volunteer.

The navigation instructions (your puzzle input) consists of a sequence of single-character actions paired with integer input values. After staring at them for a few minutes, you work out what they probably mean:

- Action N means to move north by the given value.
- Action S means to move south by the given value.
- Action E means to move east by the given value.
- Action W means to move west by the given value.
- Action L means to turn left the given number of degrees.
- Action R means to turn right the given number of degrees.
- Action F means to move forward by the given value in the direction the ship is currently facing.

The ship starts by facing east. Only the L and R actions change the direction the ship is facing. (That is, if the ship is facing east and the next instruction is N10, the ship would move north 10 units, but would still move east if the following action were F.)

For example:

```
F10
N3
F7
R90
F11
```

These instructions would be handled as follows:

- F10 would move the ship 10 units east (because the ship starts by facing east) to east 10, north 0.
- N3 would move the ship 3 units north to east 10, north 3.
- F7 would move the ship another 7 units east (because the ship is still facing east) to east 17, north 3.
- R90 would cause the ship to turn right by 90 degrees and face south; it remains at east 17, north 3.
- F11 would move the ship 11 units south to east 17, south 8.

At the end of these instructions, the ship's Manhattan distance (sum of the absolute values of its east/west position and its north/south position) from its starting position is 17 + 8 = 25.

Figure out where the navigation instructions lead. What is the Manhattan distance between that location and the ship's starting position?
"""

# ╔═╡ efaeac46-3cb0-11eb-1432-d7331fd08a65
input = let M = match.(r"([NSEWLRF])(\d+)", readlines("day12_input.txt"))
	[(Symbol(m.captures[1]), parse(Int, m.captures[2])) for m in M]
end

# ╔═╡ 81bd86d6-3cc6-11eb-21f1-d7d8b586c5aa
begin
	mutable struct Boat
		position::Vector{Float64}
		heading::Float64
	end
	Boat() = Boat([0.0, 0.0], 0.0)
end

# ╔═╡ 4cfae0ae-3cc8-11eb-27f0-49f1cf93d923
function move!(B::Boat, instruction)
	
	D = Dict(:E=>0, :N=>90, :W=>180, :S=>270, :L=>1.0, :R=>-1.0)
	i, v = instruction
	
	if i ∈ (:N, :E, :S, :W)
		dy, dx = sincosd(D[i])
		B.position = B.position .+ v .* (dx, dy)
	elseif i ∈ (:L, :R)
		B.heading = (B.heading + D[i] * v) % 360
	else
		dy, dx = sincosd(B.heading)
		B.position = B.position .+ v .* (dx, dy)
	end
	nothing
end

# ╔═╡ 3ed8cec0-3ccb-11eb-3380-05349d322aa0
md"""## Part Two

Before you can give the destination to the captain, you realize that the actual action meanings were printed on the back of the instructions the whole time.

Almost all of the actions indicate how to move a waypoint which is relative to the ship's position:

- Action N means to move the waypoint north by the given value.
- Action S means to move the waypoint south by the given value.
- Action E means to move the waypoint east by the given value.
- Action W means to move the waypoint west by the given value.
- Action L means to rotate the waypoint around the ship left (counter-clockwise) the given number of degrees.
- Action R means to rotate the waypoint around the ship right (clockwise) the given number of degrees.
- Action F means to move forward to the waypoint a number of times equal to the given value.

The waypoint starts 10 units east and 1 unit north relative to the ship. The waypoint is relative to the ship; that is, if the ship moves, the waypoint moves with it.

For example, using the same instructions as above:

- F10 moves the ship to the waypoint 10 times (a total of 100 units east and 10 units north), leaving the ship at east 100, north 10. The waypoint stays 10 units east and 1 unit north of the ship.
- N3 moves the waypoint 3 units north to 10 units east and 4 units north of the ship. The ship remains at east 100, north 10.
- F7 moves the ship to the waypoint 7 times (a total of 70 units east and 28 units north), leaving the ship at east 170, north 38. The waypoint stays 10 units east and 4 units north of the ship.
- R90 rotates the waypoint around the ship clockwise 90 degrees, moving it to 4 units east and 10 units south of the ship. The ship remains at east 170, north 38.
- F11 moves the ship to the waypoint 11 times (a total of 44 units east and 110 units south), leaving the ship at east 214, south 72. The waypoint stays 4 units east and 10 units south of the ship.

After these operations, the ship's Manhattan distance from its starting position is 214 + 72 = 286.

Figure out where the navigation instructions actually lead. What is the Manhattan distance between that location and the ship's starting position?
"""

# ╔═╡ 989d1e3e-3ccb-11eb-09f1-3bcfe5748ac6
begin
	mutable struct Waypoint
		V::Vector{Float64}
	end
	Waypoint() = Waypoint([10.0, 1.0])
end

# ╔═╡ c3689148-3ccb-11eb-1596-4fcb10e76c04
rotmat(d) = [cosd(d) -sind(d)
			 sind(d)  cosd(d)]

# ╔═╡ 99e1e35a-3ccc-11eb-148c-757d35ace426
function move!(B::Boat, W::Waypoint, instruction)
	
	D = Dict(:E=>0, :N=>90, :W=>180, :S=>270, :L=>1.0, :R=>-1.0)
	i, v = instruction
	
	if i ∈ (:N, :E, :S, :W)
		dy, dx = sincosd(D[i])
		W.V = W.V .+ v.* [dx, dy]
	elseif i ∈ (:L, :R)
		W.V = rotmat(D[i] * v) * W.V
	else
		dy, dx = sincosd(B.heading)
		B.position = B.position .+  v .* W.V
	end
	nothing
end

# ╔═╡ be02ad9e-3cc9-11eb-2f2e-c1220cd0af20
function navigate(B::Boat, directions)
	for instruction in input
		move!(B, instruction)
	end
	B
end

# ╔═╡ 7444a238-3cca-11eb-23e4-6185df72766e
ferry = navigate(Boat(), input)

# ╔═╡ f852ab06-3cca-11eb-220c-299ea354421d
sum(abs, ferry.position)

# ╔═╡ b6f6f0ec-3ccd-11eb-02b5-417b1839abbe
function navigate2(B::Boat, W::Waypoint, directions)
	for instruction in input
		move!(B, W, instruction)
	end
	B
end

# ╔═╡ a97fab84-3ccd-11eb-3f2c-a921c9541129
ferry2 = navigate2(Boat(), Waypoint(), input)

# ╔═╡ e1f111ba-3ccd-11eb-1048-ff43fd918a02
sum(abs, ferry2.position)

# ╔═╡ Cell order:
# ╟─8548f580-3cb0-11eb-3f74-c5c0d6bddb6d
# ╠═efaeac46-3cb0-11eb-1432-d7331fd08a65
# ╠═81bd86d6-3cc6-11eb-21f1-d7d8b586c5aa
# ╠═4cfae0ae-3cc8-11eb-27f0-49f1cf93d923
# ╠═be02ad9e-3cc9-11eb-2f2e-c1220cd0af20
# ╠═7444a238-3cca-11eb-23e4-6185df72766e
# ╠═f852ab06-3cca-11eb-220c-299ea354421d
# ╟─3ed8cec0-3ccb-11eb-3380-05349d322aa0
# ╠═989d1e3e-3ccb-11eb-09f1-3bcfe5748ac6
# ╠═c3689148-3ccb-11eb-1596-4fcb10e76c04
# ╠═99e1e35a-3ccc-11eb-148c-757d35ace426
# ╠═b6f6f0ec-3ccd-11eb-02b5-417b1839abbe
# ╠═a97fab84-3ccd-11eb-3f2c-a921c9541129
# ╠═e1f111ba-3ccd-11eb-1048-ff43fd918a02
