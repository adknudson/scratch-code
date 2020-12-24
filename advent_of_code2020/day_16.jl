### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 86fb679c-4542-11eb-0fc0-8514e2649186
using IntervalSets

# ╔═╡ d43682bc-44d4-11eb-352e-a54684e8f7f5
md"""# Day 16: Ticket Translation

As you're walking to yet another connecting flight, you realize that one of the legs of your re-routed trip coming up is on a high-speed train. However, the train ticket you were given is in a language you don't understand. You should probably figure out what it says before you get to the train station after the next flight.

Unfortunately, you can't actually read the words on the ticket. You can, however, read the numbers, and so you figure out the fields these tickets must have and the valid ranges for values in those fields.

You collect the rules for ticket fields, the numbers on your ticket, and the numbers on other nearby tickets for the same train service (via the airport security cameras) together into a single document you can reference (your puzzle input).

The rules for ticket fields specify a list of fields that exist somewhere on the ticket and the valid ranges of values for each field. For example, a rule like `class: 1-3 or 5-7` means that one of the fields in every ticket is named class and can be any value in the ranges 1-3 or 5-7 (inclusive, such that 3 and 5 are both valid in this field, but 4 is not).

Each ticket is represented by a single line of comma-separated values. The values are the numbers on the ticket in the order they appear; every ticket has the same format. For example, consider this ticket:

```
.--------------------------------------------------------.
| ????: 101    ?????: 102   ??????????: 103     ???: 104 |
|                                                        |
| ??: 301  ??: 302             ???????: 303      ??????? |
| ??: 401  ??: 402           ???? ????: 403    ????????? |
'--------------------------------------------------------'
```

Here, ? represents text in a language you don't understand. This ticket might be represented as 101,102,103,104,301,302,303,401,402,403; of course, the actual train tickets you're looking at are much more complicated. In any case, you've extracted just the numbers in such a way that the first number is always the same specific field, the second number is always a different specific field, and so on - you just don't know what each position actually means!

Start by determining which tickets are completely invalid; these are tickets that contain values which aren't valid for any field. Ignore your ticket for now.

For example, suppose you have the following notes:

```
class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12
```

It doesn't matter which position corresponds to which field; you can identify invalid nearby tickets by considering only whether tickets contain values that are not valid for any field. In this example, the values on the first nearby ticket are all valid for at least one field. This is not true of the other three nearby tickets: the values 4, 55, and 12 are are not valid for any field. Adding together all of the invalid values produces your ticket scanning error rate: 4 + 55 + 12 = 71.

Consider the validity of the nearby tickets you scanned. What is your ticket scanning error rate?
"""

# ╔═╡ 5483bd0c-4545-11eb-0f15-135303b9cbee
function str_to_interval(S)
	x1, x2 = parse.(Int, match(r"(\d+)-(\d+)", S).captures)
	ClosedInterval{Int}(x1, x2)
end

# ╔═╡ 91c0cfb4-4542-11eb-3a08-a1581bb00ebf
function parse_rules(rules)
	rules = match.(r"(.+): (\d+-\d+) or (\d+-\d+)", split(rules, "\n"))
	capts = [m.captures for m in rules]
	rules = Dict(c[1] => (str_to_interval(c[2]), str_to_interval(c[3])) for c in capts)
	rules
end

# ╔═╡ 267a55c6-44ee-11eb-11ea-71bcf41b56a8
function parse_input(file::String)
	input = split(join(readlines(file), "\n"), "\n\n")
	
	rules = parse_rules(input[1])
	ticket = parse.(Int, split(split(input[2], "\n")[2], ","))
	others = [parse.(Int, s) for s in split.(split(input[3], "\n")[2:end], ",")]
	
	rules, ticket, others
end

# ╔═╡ 461e63c2-4543-11eb-088e-83a2c9737ffb
begin
	in_union(a::Int, S...) = any(a .∈ S)
	in_union(A::Array{Int, 1}, S...) = [in_union(a, S...) for a in A]
	not_in_union(A::Array{Int, 1}, S...) = [!in_union(a, S...) for a in A]
	any_in_union(A::Array{Int, 1}, S...) = any(in_union(A, S...))
	all_in_union(A::Array{Int, 1}, S...) = all(in_union(A, S...))
end

# ╔═╡ 42ee29e8-44ec-11eb-2f8d-438fb276667c
rules, ticket, others = parse_input("day16_input.txt")

# ╔═╡ 1f1fa7f0-4547-11eb-10e1-a9135617f6d0
all_intervals = collect(Iterators.flatten(values(rules)))

# ╔═╡ 21ede7ba-4549-11eb-3c9b-67b46cd4d084
x = filter(x-> !isempty(x), [x[not_in_union(x, all_intervals...)] for x in others])

# ╔═╡ bf4c717c-4549-11eb-15ab-a3fd3da98642
sum(x)

# ╔═╡ e375c2d6-4549-11eb-3233-6708292fb23d
md"""## Part Two
Now that you've identified which tickets contain invalid values, discard those tickets entirely. Use the remaining valid tickets to determine which field is which.

Using the valid ranges for each field, determine what order the fields appear on the tickets. The order is consistent between all tickets: if seat is the third field, it is the third field on every ticket, including your ticket.

For example, suppose you have the following notes:

```
class: 0-1 or 4-19
row: 0-5 or 8-19
seat: 0-13 or 16-19

your ticket:
11,12,13

nearby tickets:
3,9,18
15,1,5
5,14,9
```

Based on the nearby tickets in the above example, the first position must be row, the second position must be class, and the third position must be seat; you can conclude that in your ticket, class is 12, row is 11, and seat is 13.

Once you work out which field is which, look for the six fields on your ticket that start with the word departure. What do you get if you multiply those six values together?
"""

# ╔═╡ fd9c8816-4549-11eb-3066-77f704a876a5
good_tickets = filter(x -> all_in_union(x, all_intervals...), others)

# ╔═╡ 5fe77736-454a-11eb-1528-2b976650cf04
md"""
For each ticket position, check if they all match a given rule. If they match a rule, then make the rule-position association.
"""

# ╔═╡ da62ebb0-454b-11eb-02e3-ab709b950cb2
positions = [[x[i] for x in good_tickets] for i in 1:length(rules)]

# ╔═╡ 1658a66c-454c-11eb-22a5-2b6db44c02f3
all_in_union(positions[7], rules["zone"]...)

# ╔═╡ 932ae4a2-454c-11eb-2cf3-fff919efd50e
all_in_union([49, 111], rules["zone"]...)

# ╔═╡ 2d5a1d5a-454c-11eb-0966-9d59d7dcf333
function match_rules(tickets, rules)
	d = length(rules)
	positions = [[x[i] for x in good_tickets] for i in 1:d]
	D = Dict{Int, String}()
	
	while length(D) < d
		for (i, pos) in enumerate(positions)
			i ∈ keys(D) && continue
			valid = Vector{Tuple{Int64,String}}()
			for rule in keys(rules)
				rule ∈ values(D) && continue
				if all_in_union(pos, rules[rule]...)
					push!(valid, (i, rule))
				end
			end
			if length(valid) == 1
				i, rule = valid[1]
				D[i] = rule
			end
		end
	end
	D
end

# ╔═╡ bc0fb46a-454c-11eb-0d4c-0b59213b469c
rules1 = match_rules(good_tickets, rules)

# ╔═╡ 75886eae-4550-11eb-0060-b505bf78de77
length(rules)

# ╔═╡ cad7864c-454e-11eb-2db9-af06c0aef65c
rules2 = Dict(v => k for (k, v) in rules1)

# ╔═╡ 7cd0d46e-454f-11eb-25fd-c38fd6d6640a
departure_keys = filter(x -> occursin.("departure", x), keys(rules2))

# ╔═╡ a1d36544-454f-11eb-2e32-d7dcb72cf8da
prod([ticket[rules2[x]] for x in departure_keys])

# ╔═╡ 945a8bc6-4550-11eb-22e3-3983cd8945a9


# ╔═╡ Cell order:
# ╟─d43682bc-44d4-11eb-352e-a54684e8f7f5
# ╠═86fb679c-4542-11eb-0fc0-8514e2649186
# ╠═5483bd0c-4545-11eb-0f15-135303b9cbee
# ╠═91c0cfb4-4542-11eb-3a08-a1581bb00ebf
# ╠═267a55c6-44ee-11eb-11ea-71bcf41b56a8
# ╠═461e63c2-4543-11eb-088e-83a2c9737ffb
# ╠═42ee29e8-44ec-11eb-2f8d-438fb276667c
# ╠═1f1fa7f0-4547-11eb-10e1-a9135617f6d0
# ╠═21ede7ba-4549-11eb-3c9b-67b46cd4d084
# ╠═bf4c717c-4549-11eb-15ab-a3fd3da98642
# ╟─e375c2d6-4549-11eb-3233-6708292fb23d
# ╠═fd9c8816-4549-11eb-3066-77f704a876a5
# ╟─5fe77736-454a-11eb-1528-2b976650cf04
# ╠═da62ebb0-454b-11eb-02e3-ab709b950cb2
# ╠═1658a66c-454c-11eb-22a5-2b6db44c02f3
# ╠═932ae4a2-454c-11eb-2cf3-fff919efd50e
# ╠═2d5a1d5a-454c-11eb-0966-9d59d7dcf333
# ╠═bc0fb46a-454c-11eb-0d4c-0b59213b469c
# ╠═75886eae-4550-11eb-0060-b505bf78de77
# ╠═cad7864c-454e-11eb-2db9-af06c0aef65c
# ╠═7cd0d46e-454f-11eb-25fd-c38fd6d6640a
# ╠═a1d36544-454f-11eb-2e32-d7dcb72cf8da
# ╠═945a8bc6-4550-11eb-22e3-3983cd8945a9
