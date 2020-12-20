### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 044c7de0-3d6d-11eb-0a75-792e7cf28a99
md"""# Day 13: Shuttle Search
Your ferry can make it safely to a nearby port, but it won't get much further. When you call to book another ship, you discover that no ships embark from that port to your vacation island. You'll need to get from the port to the nearest airport.

Fortunately, a shuttle bus service is available to bring you from the sea port to the airport! Each bus has an ID number that also indicates how often the bus leaves for the airport.

Bus schedules are defined based on a timestamp that measures the number of minutes since some fixed reference point in the past. At timestamp 0, every bus simultaneously departed from the sea port. After that, each bus travels to the airport, then various other locations, and finally returns to the sea port to repeat its journey forever.

The time this loop takes a particular bus is also its ID number: the bus with ID 5 departs from the sea port at timestamps 0, 5, 10, 15, and so on. The bus with ID 11 departs at 0, 11, 22, 33, and so on. If you are there when the bus departs, you can ride that bus to the airport!

Your notes (your puzzle input) consist of two lines. The first line is your estimate of the earliest timestamp you could depart on a bus. The second line lists the bus IDs that are in service according to the shuttle company; entries that show x must be out of service, so you decide to ignore them.

To save time once you arrive, your goal is to figure out the earliest bus you can take to the airport. (There will be exactly one such bus.)

For example, suppose you have the following notes:

```
939
7,13,x,x,59,x,31,19
```

Here, the earliest timestamp you could depart is 939, and the bus IDs in service are 7, 13, 59, 31, and 19. Near timestamp 939, these bus IDs depart at the times marked D:

```
time   bus 7   bus 13  bus 59  bus 31  bus 19
929      .       .       .       .       .
930      .       .       .       D       .
931      D       .       .       .       D
932      .       .       .       .       .
933      .       .       .       .       .
934      .       .       .       .       .
935      .       .       .       .       .
936      .       D       .       .       .
937      .       .       .       .       .
938      D       .       .       .       .
939      .       .       .       .       .
940      .       .       .       .       .
941      .       .       .       .       .
942      .       .       .       .       .
943      .       .       .       .       .
944      .       .       D       .       .
945      D       .       .       .       .
946      .       .       .       .       .
947      .       .       .       .       .
948      .       .       .       .       .
949      .       D       .       .       .
```

The earliest bus you could take is bus ID 59. It doesn't depart until timestamp 944, so you would need to wait 944 - 939 = 5 minutes before it departs. Multiplying the bus ID by the number of minutes you'd need to wait gives 295.

What is the ID of the earliest bus you can take to the airport multiplied by the number of minutes you'll need to wait for that bus?
"""

# ╔═╡ a05d3044-4231-11eb-385a-bd96252c0153
arrival, buses = open("day13_input.txt") do f
	arrival = parse(Int, readline(f))
	buses = split(readline(f), ",")
	filter!(!=("x"), buses)
	buses = parse.(Int, buses)
	(arrival, buses)
end

# ╔═╡ 0cda6160-4232-11eb-1e98-5155fb11c7a3
res = buses .- mod.(arrival, buses)

# ╔═╡ 47964ba6-4233-11eb-26c3-559b645c99e0
minimum(res) * buses[argmin(res)]

# ╔═╡ 5c9ca6e4-4233-11eb-2fd7-bb65f6e7280e
md"""## Part Two

The shuttle company is running a contest: one gold coin for anyone that can find the earliest timestamp such that the first bus ID departs at that time and each subsequent listed bus ID departs at that subsequent minute. (The first line in your input is no longer relevant.)

For example, suppose you have the same list of bus IDs as above:

```
7,13,x,x,59,x,31,19
```

An x in the schedule means there are no constraints on what bus IDs must depart at that time.

This means you are looking for the earliest timestamp (called t) such that:

- Bus ID 7 departs at timestamp t.
- Bus ID 13 departs one minute after timestamp t.
- There are no requirements or restrictions on departures at two or three minutes after timestamp t.
- Bus ID 59 departs four minutes after timestamp t.
- There are no requirements or restrictions on departures at five minutes after timestamp t.
- Bus ID 31 departs six minutes after timestamp t.
- Bus ID 19 departs seven minutes after timestamp t.

The only bus departures that matter are the listed bus IDs at their specific offsets from t. Those bus IDs can depart at other times, and other bus IDs can depart at those times. For example, in the list above, because bus ID 19 must depart seven minutes after the timestamp at which bus ID 7 departs, bus ID 7 will always also be departing with bus ID 19 at seven minutes after timestamp t.

In this example, the earliest timestamp at which this occurs is 1068781:

```
time     bus 7   bus 13  bus 59  bus 31  bus 19
1068773    .       .       .       .       .
1068774    D       .       .       .       .
1068775    .       .       .       .       .
1068776    .       .       .       .       .
1068777    .       .       .       .       .
1068778    .       .       .       .       .
1068779    .       .       .       .       .
1068780    .       .       .       .       .
1068781    D       .       .       .       .
1068782    .       D       .       .       .
1068783    .       .       .       .       .
1068784    .       .       .       .       .
1068785    .       .       D       .       .
1068786    .       .       .       .       .
1068787    .       .       .       D       .
1068788    D       .       .       .       D
1068789    .       .       .       .       .
1068790    .       .       .       .       .
1068791    .       .       .       .       .
1068792    .       .       .       .       .
1068793    .       .       .       .       .
1068794    .       .       .       .       .
1068795    D       D       .       .       .
1068796    .       .       .       .       .
1068797    .       .       .       .       .
```

In the above example, bus ID 7 departs at timestamp 1068788 (seven minutes after t). This is fine; the only requirement on that minute is that bus ID 19 departs then, and it does.

Here are some other examples:

- The earliest timestamp that matches the list `17,x,13,19` is `3417`.
- `67,7,59,61` first occurs at timestamp `754018`.
- `67,x,7,59,61` first occurs at timestamp `779210`.
- `67,7,x,59,61` first occurs at timestamp `1261476`.
- `1789,37,47,1889` first occurs at timestamp `1202161486`.

However, with so many bus IDs in your list, surely the actual earliest timestamp will be larger than 100000000000000!

What is the earliest timestamp such that all of the listed bus IDs depart at offsets matching their positions in the list?
"""

# ╔═╡ 37c0cc24-4233-11eb-08ba-bf0001065688
b = open("day13_input.txt") do f
	readline(f)
	buses = split(readline(f), ",")
	1 .- findall(!=("x"), buses)
end

# ╔═╡ e81a738e-4244-11eb-07a2-91244357e805
m = buses

# ╔═╡ dfb68b84-4243-11eb-076f-cb2950f03dad
function solve_ax_eq_1_mod_m(a, m)
	a = a % m
	i = 1
	while true
		a*i % m == 1 && return i
		i += 1
	end
end

# ╔═╡ 485e94e2-4244-11eb-178b-dd01f61bf9d7
function Sun_Tsu(b, m)
	M = prod(m)
	c = b .% m
	n = M .÷ m
	ñ = [solve_ax_eq_1_mod_m(ni, mi) for (ni, mi) in zip(n, m)]
	x₀ = sum(c .* n .* ñ)
	ret = x₀ % M
	ret < 0 ? ret + M : ret
end	

# ╔═╡ 305902dc-4245-11eb-1905-ebc522c990c5
Sun_Tsu(b, m)

# ╔═╡ Cell order:
# ╟─044c7de0-3d6d-11eb-0a75-792e7cf28a99
# ╠═a05d3044-4231-11eb-385a-bd96252c0153
# ╠═0cda6160-4232-11eb-1e98-5155fb11c7a3
# ╠═47964ba6-4233-11eb-26c3-559b645c99e0
# ╟─5c9ca6e4-4233-11eb-2fd7-bb65f6e7280e
# ╠═37c0cc24-4233-11eb-08ba-bf0001065688
# ╠═e81a738e-4244-11eb-07a2-91244357e805
# ╠═dfb68b84-4243-11eb-076f-cb2950f03dad
# ╠═485e94e2-4244-11eb-178b-dd01f61bf9d7
# ╠═305902dc-4245-11eb-1905-ebc522c990c5
