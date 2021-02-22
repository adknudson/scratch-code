### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ f9aa7888-745d-11eb-1f2f-b9b76833cf5e
using Distributions

# ╔═╡ 34eeac58-745d-11eb-1fc6-757d58944796
using Bigsimr

# ╔═╡ 3e471100-745d-11eb-0348-c50c6d5265c9
Bigsimr._rmvn(n::Int, p::Float64) = Bigsimr._rmvn(n, [1.0 p; p 1.0])

# ╔═╡ b62a46ea-7414-11eb-3199-2b49845c091f
function f(x, F₁, F₂; n::Int=1_000_000)
	r = [1.0 x; x 1.0]
	z = Bigsimr._rmvn(n, x)
	z[:,1] = Bigsimr.normal_to_margin(F₁, z[:,1])
	z[:,2] = Bigsimr.normal_to_margin(F₂, z[:,2])
	cor(z)
end

# ╔═╡ 2e7e06ec-745e-11eb-3104-37f09704416d
f(-0.72, Exponential(1), Exponential(1), n=2_048)

# ╔═╡ 865211c4-745e-11eb-2419-d141359dbf6a
pearson_match(-0.5, Exponential(1), Exponential(1))

# ╔═╡ Cell order:
# ╠═f9aa7888-745d-11eb-1f2f-b9b76833cf5e
# ╠═34eeac58-745d-11eb-1fc6-757d58944796
# ╠═3e471100-745d-11eb-0348-c50c6d5265c9
# ╠═b62a46ea-7414-11eb-3199-2b49845c091f
# ╠═2e7e06ec-745e-11eb-3104-37f09704416d
# ╠═865211c4-745e-11eb-2419-d141359dbf6a
