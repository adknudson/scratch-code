### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ c5310ed8-3b04-11eb-3c2f-551d43ce964e
md"""
# Day 10: Adapter Array

Patched into the aircraft's data port, you discover weather forecasts of a massive tropical storm. Before you can figure out whether it will impact your vacation plans, however, your device suddenly turns off!

Its battery is dead.

You'll need to plug it in. There's only one problem: the charging outlet near your seat produces the wrong number of **jolts**. Always prepared, you make a list of all of the joltage adapters in your bag.

Each of your joltage adapters is rated for a specific **output joltage** (your puzzle input). Any given adapter can take an input `1`, `2`, or `3` jolts **lower** than its rating and still produce its rated output joltage.

In addition, your device has a built-in joltage adapter rated for `3` **jolts higher** than the highest-rated adapter in your bag. (If your adapter list were `3`, `9`, and `6`, your device's built-in adapter would be rated for `12` jolts.)

Treat the charging outlet near your seat as having an effective joltage rating of `0`.

Since you have some time to kill, you might as well test all of your adapters. Wouldn't want to get to your resort and realize you can't even charge your device!

If you use **every adapter in your bag** at once, what is the distribution of joltage differences between the charging outlet, the adapters, and your device?

For example, suppose that in your bag, you have adapters with the following joltage ratings:

```
16
10
15
5
1
11
7
19
6
12
4
```

With these adapters, your device's built-in joltage adapter would be rated for `19 + 3 = 22` jolts, 3 higher than the highest-rated adapter.

Because adapters can only connect to a source 1-3 jolts lower than its rating, in order to use every adapter, you'd need to choose them like this:

- The charging outlet has an effective rating of 0 jolts, so the only adapters that could connect to it directly would need to have a joltage rating of 1, 2, or 3 jolts. Of these, only one you have is an adapter rated 1 jolt (difference of 1).
- From your 1-jolt rated adapter, the only choice is your 4-jolt rated adapter (difference of 3).
- From the 4-jolt rated adapter, the adapters rated 5, 6, or 7 are valid choices. However, in order to not skip any adapters, you have to pick the adapter rated 5 jolts (difference of 1).
- Similarly, the next choices would need to be the adapter rated 6 and then the adapter rated 7 (with difference of 1 and 1).
- The only adapter that works with the 7-jolt rated adapter is the one rated 10 jolts (difference of 3).
- From 10, the choices are 11 or 12; choose 11 (difference of 1) and then 12 (difference of 1).
- After 12, only valid adapter has a rating of 15 (difference of 3), then 16 (difference of 1), then 19 (difference of 3).
- Finally, your device's built-in adapter is always 3 higher than the highest adapter, so its rating is 22 jolts (always a difference of 3).
- In this example, when using every adapter, there are 7 differences of 1 jolt and 5 differences of 3 jolts.

Here is a larger example:

```
28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3
```

In this larger example, in a chain that uses all of the adapters, there are `22` differences of 1 jolt and `10` differences of 3 jolts.

Find a chain that uses all of your adapters to connect the charging outlet to your device's built-in adapter and count the joltage differences between the charging outlet, the adapters, and your device. **What is the number of 1-jolt differences multiplied by the number of 3-jolt differences?**
"""

# ╔═╡ c3f7002c-3b09-11eb-39fe-bfda26bc2f80
input = sort!(parse.(Int, readlines("day10_input.txt")))

# ╔═╡ fec71982-3b25-11eb-3cbb-01f05708b04d
insert!(input, 1, 0)

# ╔═╡ ed72e3aa-3b25-11eb-0526-99bc1cc8d5b5
push!(input, last(input)+3)

# ╔═╡ dbe6b72e-3b25-11eb-1a94-0dcc8696e1c3
diff_distr = diff(input)

# ╔═╡ 48922758-3b26-11eb-2ff0-bf0ad9e077ee
diff_table = Dict(i => sum(diff_distr .== i) for i in unique(diff_distr))

# ╔═╡ 5a057418-3b26-11eb-30ce-eb43259753c1
diff_table[1] * diff_table[3]

# ╔═╡ c47168e0-3b26-11eb-1619-61378a553fb2
md"""
## Part Two

To completely determine whether you have enough adapters, you'll need to figure out how many different ways they can be arranged. Every arrangement needs to connect the charging outlet to your device. The previous rules about when adapters can successfully connect still apply.

The first example above (the one that starts with 16, 10, 15) supports the following arrangements:

```
(0), 1, 4, 5, 6, 7, 10, 11, 12, 15, 16, 19, (22)
(0), 1, 4, 5, 6, 7, 10, 12, 15, 16, 19, (22)
(0), 1, 4, 5, 7, 10, 11, 12, 15, 16, 19, (22)
(0), 1, 4, 5, 7, 10, 12, 15, 16, 19, (22)
(0), 1, 4, 6, 7, 10, 11, 12, 15, 16, 19, (22)
(0), 1, 4, 6, 7, 10, 12, 15, 16, 19, (22)
(0), 1, 4, 7, 10, 11, 12, 15, 16, 19, (22)
(0), 1, 4, 7, 10, 12, 15, 16, 19, (22)
```

(The charging outlet and your device's built-in adapter are shown in parentheses.) Given the adapters from the first example, the total number of arrangements that connect the charging outlet to your device is 8.

The second example above (the one that starts with 28, 33, 18) has many arrangements. Here are a few:

```
(0), 1, 2, 3, 4, 7, 8, 9, 10, 11, 14, 17, 18, 19, 20, 23, 24, 25, 28, 31,
32, 33, 34, 35, 38, 39, 42, 45, 46, 47, 48, 49, (52)

(0), 1, 2, 3, 4, 7, 8, 9, 10, 11, 14, 17, 18, 19, 20, 23, 24, 25, 28, 31,
32, 33, 34, 35, 38, 39, 42, 45, 46, 47, 49, (52)

(0), 1, 2, 3, 4, 7, 8, 9, 10, 11, 14, 17, 18, 19, 20, 23, 24, 25, 28, 31,
32, 33, 34, 35, 38, 39, 42, 45, 46, 48, 49, (52)

(0), 1, 2, 3, 4, 7, 8, 9, 10, 11, 14, 17, 18, 19, 20, 23, 24, 25, 28, 31,
32, 33, 34, 35, 38, 39, 42, 45, 46, 49, (52)

(0), 1, 2, 3, 4, 7, 8, 9, 10, 11, 14, 17, 18, 19, 20, 23, 24, 25, 28, 31,
32, 33, 34, 35, 38, 39, 42, 45, 47, 48, 49, (52)

(0), 3, 4, 7, 10, 11, 14, 17, 20, 23, 25, 28, 31, 34, 35, 38, 39, 42, 45,
46, 48, 49, (52)

(0), 3, 4, 7, 10, 11, 14, 17, 20, 23, 25, 28, 31, 34, 35, 38, 39, 42, 45,
46, 49, (52)

(0), 3, 4, 7, 10, 11, 14, 17, 20, 23, 25, 28, 31, 34, 35, 38, 39, 42, 45,
47, 48, 49, (52)

(0), 3, 4, 7, 10, 11, 14, 17, 20, 23, 25, 28, 31, 34, 35, 38, 39, 42, 45,
47, 49, (52)

(0), 3, 4, 7, 10, 11, 14, 17, 20, 23, 25, 28, 31, 34, 35, 38, 39, 42, 45,
48, 49, (52)
```

In total, this set of adapters can connect the charging outlet to your device in 19208 distinct arrangements.

You glance back down at your bag and try to remember why you brought so many adapters; there must be more than a trillion valid ways to arrange them! Surely, there must be an efficient way to count the arrangements.

**What is the total number of distinct ways you can arrange the adapters to connect the charging outlet to your device?**
"""

# ╔═╡ 5925856e-3b29-11eb-1cc6-ff9658e8421e
function P(V::Vector{Int}, k::Int, D=Dict{Int, Int}())
	if haskey(D, k)
		return D[k]
	elseif k ∉ V
		D[k] = 0
		return D[k]
	elseif k == minimum(V)
		return 1
	else
		D[k] = P(V, k-1, D) + P(V, k-2, D) + P(V, k-3, D)
		return D[k]
	end
end

# ╔═╡ 2a6bb3d0-3b31-11eb-35a0-cf5f23e740e1
P(input, maximum(input))

# ╔═╡ 9ebb81a2-3b7c-11eb-25d5-5381d8a86700


# ╔═╡ Cell order:
# ╟─c5310ed8-3b04-11eb-3c2f-551d43ce964e
# ╠═c3f7002c-3b09-11eb-39fe-bfda26bc2f80
# ╠═fec71982-3b25-11eb-3cbb-01f05708b04d
# ╠═ed72e3aa-3b25-11eb-0526-99bc1cc8d5b5
# ╠═dbe6b72e-3b25-11eb-1a94-0dcc8696e1c3
# ╠═48922758-3b26-11eb-2ff0-bf0ad9e077ee
# ╠═5a057418-3b26-11eb-30ce-eb43259753c1
# ╟─c47168e0-3b26-11eb-1619-61378a553fb2
# ╠═5925856e-3b29-11eb-1cc6-ff9658e8421e
# ╠═2a6bb3d0-3b31-11eb-35a0-cf5f23e740e1
# ╠═9ebb81a2-3b7c-11eb-25d5-5381d8a86700
