### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 89acfe4a-4607-11eb-13de-0da2bef1b3e9
md"""# Day 19: Monster Messages

You land in an airport surrounded by dense forest. As you walk to your high-speed train, the Elves at the Mythical Information Bureau contact you again. They think their satellite has collected an image of a sea monster! Unfortunately, the connection to the satellite is having problems, and many of the messages sent back from the satellite have been corrupted.

They sent you a list of the rules valid messages should obey and a list of received messages they've collected so far (your puzzle input).

The rules for valid messages (the top part of your puzzle input) are numbered and build upon each other. For example:

```
0: 1 2
1: "a"
2: 1 3 | 3 1
3: "b"
```

Some rules, like `3: "b"`, simply match a single character (in this case, b).

The remaining rules list the sub-rules that must be followed; for example, the rule `0: 1 2` means that to match rule 0, the text being checked must match rule 1, and the text after the part that matched rule 1 must then match rule 2.

Some of the rules have multiple lists of sub-rules separated by a pipe (|). This means that at least one list of sub-rules must match. (The ones that match might be different each time the rule is encountered.) For example, the rule `2: 1 3 | 3 1` means that to match rule 2, the text being checked must match rule 1 followed by rule 3 or it must match rule 3 followed by rule 1.

Fortunately, there are no loops in the rules, so the list of possible matches will be finite. Since rule `1` matches `a` and rule `3` matches `b`, rule `2` matches either `ab` or `ba`. Therefore, rule `0` matches `aab` or `aba`.

Here's a more interesting example:

```
0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"
```

Here, because rule `4` matches `a` and rule `5` matches `b`, rule `2` matches two letters that are the same (`aa` or `bb`), and rule `3` matches two letters that are different (`ab` or `ba`).

Since rule `1` matches rules `2` and `3` once each in either order, it must match two pairs of letters, one pair with matching letters and one pair with different letters. This leaves eight possibilities: `aaab`, `aaba`, `bbab`, `bbba`, `abaa`, `abbb`, `baaa`, or `babb`.

Rule `0`, therefore, matches `a` (rule `4`), then any of the eight options from rule `1`, then `b` (rule `5`): `aaaabb`, `aaabab`, `abbabb`, `abbbab`, `aabaab`, `aabbbb`, `abaaab`, or `ababbb`.

The received messages (the bottom part of your puzzle input) need to be checked against the rules so you can determine which are valid and which are corrupted. Including the rules and the messages together, this might look like:

```
0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"

ababbb
bababa
abbbab
aaabbb
aaaabbb
```

Your goal is to determine the number of messages that completely match rule `0`. In the above example, `ababbb` and `abbbab` match, but `bababa`, `aaabbb`, and `aaaabbb` do not, producing the answer `2`. The whole message must match all of rule `0`; there can't be extra unmatched characters in the message. (For example, `aaaabbb` might appear to match rule `0` above, but it has an extra unmatched `b` on the end.)

How many messages completely match rule 0?
"""

# ╔═╡ d328d674-4608-11eb-0a70-511ed338e409
rules, message = (split(x, "\n") for x in split.(join(readlines("day19_input.txt"), "\n"), "\n\n"));

# ╔═╡ 224728c6-4609-11eb-0069-a1a3b6c6688e
rules

# ╔═╡ 2db30f9a-46d3-11eb-262e-a76b0e721d52
function parse_rules(rules)
	x = [m.captures for m in match.(r"(\d+): (.*)", rules)]
	D = Dict(k => val for (k, val) in x)
	rule_0 = D["0"]
	delete!(D, "0")
	
	for (k,v) in D
		D[k] = occursin(r"[a-z]", v) ? match(r"([a-z])", v).captures[1] : v
	end
	
	rule_0, D
end

# ╔═╡ 564867da-47bb-11eb-18e7-df5d7f745cbb
rule_zero, D = parse_rules(rules)

# ╔═╡ f4d331be-47b8-11eb-1ec9-e158382fef39
p(s) = join(["(", s, ")"])

# ╔═╡ 2c3de3e4-47bc-11eb-3c1c-6b25e267035b
a(s) = join(["^", s, "\$"])

# ╔═╡ b7999e54-47b9-11eb-0a44-cd2138dc2174
function replace_rules(rule_zero, d)
	r = p(String(rule_zero))
	while occursin(r"\d", r)
		for (k, v) in D
			r = replace(r, k => p(v))
		end
	end
	Regex(a(replace(r, " " => "")))
end

# ╔═╡ 03978720-47bb-11eb-1109-6319b46aa187
rule_regex = replace_rules(rule_zero, D)

# ╔═╡ 6fe0fe46-47bb-11eb-2734-0d3052062aa0
# rule_matches = match.(rule_regex, message) .!== nothing

# ╔═╡ 722cd172-47bb-11eb-1f6f-ada77a70578b


# ╔═╡ Cell order:
# ╟─89acfe4a-4607-11eb-13de-0da2bef1b3e9
# ╠═d328d674-4608-11eb-0a70-511ed338e409
# ╠═224728c6-4609-11eb-0069-a1a3b6c6688e
# ╠═2db30f9a-46d3-11eb-262e-a76b0e721d52
# ╠═564867da-47bb-11eb-18e7-df5d7f745cbb
# ╠═f4d331be-47b8-11eb-1ec9-e158382fef39
# ╠═2c3de3e4-47bc-11eb-3c1c-6b25e267035b
# ╠═b7999e54-47b9-11eb-0a44-cd2138dc2174
# ╠═03978720-47bb-11eb-1109-6319b46aa187
# ╠═6fe0fe46-47bb-11eb-2734-0d3052062aa0
# ╠═722cd172-47bb-11eb-1f6f-ada77a70578b
