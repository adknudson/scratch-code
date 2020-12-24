### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ a5dd4570-45c3-11eb-3abc-0bef2f932078
md"""# Day 18: Operation Order

As you look out the window and notice a heavily-forested continent slowly appear over the horizon, you are interrupted by the child sitting next to you. They're curious if you could help them with their math homework.

Unfortunately, it seems like this "math" follows different rules than you remember.

The homework (your puzzle input) consists of a series of expressions that consist of addition (+), multiplication (*), and parentheses ((...)). Just like normal math, parentheses indicate that the expression inside must be evaluated before it can be used by the surrounding expression. Addition still finds the sum of the numbers on both sides of the operator, and multiplication still finds the product.

However, the rules of operator precedence have changed. Rather than evaluating multiplication before addition, the operators have the same precedence, and are evaluated left-to-right regardless of the order in which they appear.

For example, the steps to evaluate the expression `1 + 2 * 3 + 4 * 5 + 6` are as follows:

```
1 + 2 * 3 + 4 * 5 + 6
  3   * 3 + 4 * 5 + 6
      9   + 4 * 5 + 6
         13   * 5 + 6
             65   + 6
                 71
```

Parentheses can override this order; for example, here is what happens if parentheses are added to form 1 + (2 * 3) + (4 * (5 + 6)):

```
1 + (2 * 3) + (4 * (5 + 6))
1 +    6    + (4 * (5 + 6))
     7      + (4 * (5 + 6))
     7      + (4 *   11   )
     7      +     44
            51
```

Here are a few more examples:

- `2 * 3 + (4 * 5)` becomes 26.
- `5 + (8 * 3 + 9 + 3 * 4 * 3)` becomes 437.
- `5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))` becomes 12240.
- `((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2` becomes 13632.

Before you can help with the homework, you need to understand it yourself. Evaluate the expression on each line of the homework; what is the sum of the resulting values?
"""

# ╔═╡ 459c7e1c-45c4-11eb-03e9-4310663c8bf9
Base.operator_precedence(:⊕), Base.operator_precedence(:+)

# ╔═╡ 968ed428-45c4-11eb-1fe6-0d735ecabfda
⊕(a, b) = a * b

# ╔═╡ e3b0ff06-45c4-11eb-3358-1575c9d18df5
math = [Meta.parse(replace(s, "*" => "⊕")) for s in readlines("day18_input.txt")]

# ╔═╡ dea078ee-45c8-11eb-32e8-cb24e565b529
sum(eval, math)

# ╔═╡ 05d9e58a-45c9-11eb-0d10-ab4bc528e254
md"""## Part Two

You manage to answer the child's questions and they finish part 1 of their homework, but get stuck when they reach the next section: advanced math.

Now, addition and multiplication have different precedence levels, but they're not the ones you're familiar with. Instead, addition is evaluated before multiplication.

For example, the steps to evaluate the expression `1 + 2 * 3 + 4 * 5 + 6` are now as follows:

```
1 + 2 * 3 + 4 * 5 + 6
  3   * 3 + 4 * 5 + 6
  3   *   7   * 5 + 6
  3   *   7   *  11
     21       *  11
         231
```

Here are the other examples from above:

- `1 + (2 * 3) + (4 * (5 + 6))` still becomes 51.
- `2 * 3 + (4 * 5)` becomes 46.
- `5 + (8 * 3 + 9 + 3 * 4 * 3)` becomes 1445.
- `5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))` becomes 669060.
- `((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2` becomes 23340.


What do you get if you add up the results of evaluating the homework problems using these new rules?
"""

# ╔═╡ 4c0c74c8-45c9-11eb-15ce-2f9f570dcd49
⊗(a, b) = a + b

# ╔═╡ 40ffbcf6-45ca-11eb-1110-b1591d5169dd
advanced_math = [
	Meta.parse(
		replace(replace(s, "*" => "⊕"), "+" => "⊗")
	) for s in readlines("day18_input.txt")
]

# ╔═╡ 54b84d42-45ca-11eb-125d-7919d386ff22
sum(eval, advanced_math)

# ╔═╡ Cell order:
# ╟─a5dd4570-45c3-11eb-3abc-0bef2f932078
# ╠═459c7e1c-45c4-11eb-03e9-4310663c8bf9
# ╠═968ed428-45c4-11eb-1fe6-0d735ecabfda
# ╠═e3b0ff06-45c4-11eb-3358-1575c9d18df5
# ╠═dea078ee-45c8-11eb-32e8-cb24e565b529
# ╟─05d9e58a-45c9-11eb-0d10-ab4bc528e254
# ╠═4c0c74c8-45c9-11eb-15ce-2f9f570dcd49
# ╠═40ffbcf6-45ca-11eb-1110-b1591d5169dd
# ╠═54b84d42-45ca-11eb-125d-7919d386ff22
