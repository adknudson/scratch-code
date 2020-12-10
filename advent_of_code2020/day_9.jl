### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ a5236852-3b11-11eb-27c2-8ba4ebe2cf26
using OffsetArrays, IterTools

# ╔═╡ 4a25fa2a-3b05-11eb-3dc5-218910f4128a
md"""
# Day 9: Encoding Error

With your neighbor happily enjoying their video game, you turn your attention to an open data port on the little screen in the seat in front of you.

Though the port is non-standard, you manage to connect it to your computer through the clever use of several paperclips. Upon connection, the port outputs a series of numbers (your puzzle input).

The data appears to be encrypted with the eXchange-Masking Addition System (XMAS) which, conveniently for you, is an old cypher with an important weakness.

XMAS starts by transmitting a **preamble** of 25 numbers. After that, each number you receive should be the sum of any two of the 25 immediately previous numbers. The two numbers will have different values, and there might be more than one such pair.

For example, suppose your preamble consists of the numbers `1` through `25` in a random order. To be valid, the next number must be the sum of two of those numbers:

- `26` would be a **valid** next number, as it could be `1` plus `25` (or many other pairs, like `2` and `24`).
- `49` would be a **valid** next number, as it is the sum of `24` and `25`.
- `100` would **not** be valid; no two of the previous 25 numbers sum to `100`.
- `50` would also **not** be valid; although `25` appears in the previous 25 numbers, the two numbers in the pair must be different.

Suppose the 26th number is `45`, and the first number (no longer an option, as it is more than 25 numbers ago) was `20`. Now, for the next number to be valid, there needs to be some pair of numbers among `1-19`, `21-25`, or `45` that add up to it:

- `26` would still be a **valid** next number, as `1` and `25` are still within the previous 25 numbers.
- `65` would **not** be valid, as no two of the available numbers sum to it.
- `64` and `66` would both be **valid**, as they are the result of `19+45` and `21+45` respectively.

Here is a larger example which only considers the previous 5 numbers (and has a preamble of length 5):

```
35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576
```

In this example, after the 5-number preamble, almost every number is the sum of two of the previous 5 numbers; the only number that does not follow this rule is `127`.

The first step of attacking the weakness in the XMAS data is to find the first number in the list (after the preamble) which is not the sum of two of the 25 numbers before it. **What is the first number that does not have this property?**


"""

# ╔═╡ e0c8cf1c-3b10-11eb-2951-a53eecf0371c
md"""
## My Idea

Use offset arrays to store the input with indices $[-d+1, -d+2, ..., 0, 1, ... n]$ where $n$ is the number of numbers *after* the preamble, and $d$ is the length of the preamble.

Then I can reference the preceding numbers as $(A[i-d:i-1], A[i])$
"""

# ╔═╡ 006f8e7e-3b12-11eb-0273-bd69fc0bfd36
struct XMAS
	d::Int
	n::Int
	A::OffsetVector
	XMAS(d, str) = begin
		x = parse.(Int, readlines(str))
		n = length(x) - d
		new(d, n, OffsetVector(x, -d+1:n))
	end
end

# ╔═╡ a3ec004e-3b12-11eb-1e78-516bc3ce7152
Base.getindex(X::XMAS, i) = getindex(X.A, i)

# ╔═╡ 9ae73e14-3b17-11eb-1448-cde659ccc526
Base.eachindex(X::XMAS) = eachindex(X.A)

# ╔═╡ 45b0c9e6-3b13-11eb-3d37-1d56f6f49772
Base.size(X::XMAS) = size(X.A)

# ╔═╡ 5a1c9cfc-3b13-11eb-0522-f189792ac4cb
preamble(X::XMAS, i) = (X[i-X.d:i-1], X[i])

# ╔═╡ 8e362bda-3b12-11eb-1b89-67b27ef785ce
A = XMAS(25, "day9_input.txt");

# ╔═╡ 134b3ada-3b14-11eb-2590-b7c2163a6d5b
function debug(X::XMAS)
	for i in 1:X.n
		p, t = preamble(X, i)
		t ∉ Set(sum(a) for a in subsets(p, Val{2}())) && return (index=i, value=t)
	end
end

# ╔═╡ 0afdc21c-3b14-11eb-15b1-ed6b18356f5f
debug(A)

# ╔═╡ 67dfc938-3b14-11eb-107b-0d75d47b5570
md"""
## Part Two

The final step in breaking the XMAS encryption relies on the invalid number you just found: you must **find a contiguous set of at least two numbers** in your list which sum to the invalid number from step 1.

Again consider the above example:

```
35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576
```

In this list, adding up all of the numbers from 15 through 40 produces the invalid number from step 1, 127. (Of course, the contiguous set of numbers in your actual list might be much longer.)

To find the **encryption weakness**, add together the **smallest** and **largest** number in this contiguous range; in this example, these are `15` and `47`, producing `62`.

**What is the encryption weakness in your XMAS-encrypted list of numbers?**
"""

# ╔═╡ ea5997fa-3b15-11eb-1de0-13376ed9a412
function hack(X::XMAS)
	i, v = debug(X)
	for n in 3:X.n
		for s in partition(X.A, n, 1)
			sum(s) == v && return s
		end
	end
end

# ╔═╡ 97bf08a8-3b16-11eb-2dc3-17ca57dd79b3
ret = hack(A)

# ╔═╡ 60c0559e-3b18-11eb-3337-8524e63ce9e3
minimum(ret) + maximum(ret)

# ╔═╡ Cell order:
# ╟─4a25fa2a-3b05-11eb-3dc5-218910f4128a
# ╟─e0c8cf1c-3b10-11eb-2951-a53eecf0371c
# ╠═a5236852-3b11-11eb-27c2-8ba4ebe2cf26
# ╠═006f8e7e-3b12-11eb-0273-bd69fc0bfd36
# ╠═a3ec004e-3b12-11eb-1e78-516bc3ce7152
# ╠═9ae73e14-3b17-11eb-1448-cde659ccc526
# ╠═45b0c9e6-3b13-11eb-3d37-1d56f6f49772
# ╠═5a1c9cfc-3b13-11eb-0522-f189792ac4cb
# ╠═8e362bda-3b12-11eb-1b89-67b27ef785ce
# ╠═134b3ada-3b14-11eb-2590-b7c2163a6d5b
# ╠═0afdc21c-3b14-11eb-15b1-ed6b18356f5f
# ╟─67dfc938-3b14-11eb-107b-0d75d47b5570
# ╠═ea5997fa-3b15-11eb-1de0-13376ed9a412
# ╠═97bf08a8-3b16-11eb-2dc3-17ca57dd79b3
# ╠═60c0559e-3b18-11eb-3337-8524e63ce9e3
