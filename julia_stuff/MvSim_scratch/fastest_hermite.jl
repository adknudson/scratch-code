### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 350c36fa-5467-11eb-2f5e-a976f28e61b7
using BenchmarkTools, Memoize, FastGaussQuadrature

# ╔═╡ 8076ec9e-5469-11eb-12af-d35ce26afeb8
md""" # Reconstructing Xiao/Zhou Hermite Polynomial

The paper describes the Hermite polynomial by the following recurrence relation:

$H_0(z) = 1, \quad H_1(z) = z, \quad H_{k+1} = z H_k (z) - H_{k}^{\prime}(z)$

where

$H_{n}^{\prime}(z) = n H_{n-1}(z)$

This is more formally known as the *probabilist's* Hermite polynomial. There is a known theorem where every recursive function can be re-written with loops.


"""

# ╔═╡ 7b39773a-5467-11eb-1702-7b1722891203
@memoize function h1(x::Float64, n::Int)
    if n == 0
        return 1.0
    elseif n == 1
        return x
    else
        return x * h1(x, n-1) - (n-1) * h1(x, n-2)
    end
end

# ╔═╡ 323c2fdc-546c-11eb-04c0-fffe112ecc0c
function h3(x::Float64, n::Int)
	if n == 0
		return 1.0
	elseif n == 1
		return x
	end
	
	Hkp1, Hk, Hkm1 = 0.0, x, 1.0
	for k in 2:n
		Hkp1 = x*Hk - (k-1) * Hkm1
		Hkm1, Hk = Hk, Hkp1
	end
	Hkp1
end

# ╔═╡ bd442592-546e-11eb-2167-55f2eb35d02d
n = 0:2:10

# ╔═╡ 8d816e5c-5467-11eb-29eb-41bfe136537e
[h1(Float64(π), m) for m in n]

# ╔═╡ 58c612d0-546c-11eb-275d-7b15a3f24d92
[h3(Float64(π), m) for m in n]

# ╔═╡ c1cfba16-546b-11eb-06e1-3b6423e2e48d
@benchmark h1(2.0, 21)

# ╔═╡ c160b48a-546c-11eb-1abf-f57d69b2b9df
@benchmark h3(2.0, 21)

# ╔═╡ 099edc30-5473-11eb-2a5f-c5767a074b95
gausshermite(10)

# ╔═╡ Cell order:
# ╠═350c36fa-5467-11eb-2f5e-a976f28e61b7
# ╟─8076ec9e-5469-11eb-12af-d35ce26afeb8
# ╠═7b39773a-5467-11eb-1702-7b1722891203
# ╠═323c2fdc-546c-11eb-04c0-fffe112ecc0c
# ╠═bd442592-546e-11eb-2167-55f2eb35d02d
# ╠═8d816e5c-5467-11eb-29eb-41bfe136537e
# ╠═58c612d0-546c-11eb-275d-7b15a3f24d92
# ╠═c1cfba16-546b-11eb-06e1-3b6423e2e48d
# ╠═c160b48a-546c-11eb-1abf-f57d69b2b9df
# ╠═099edc30-5473-11eb-2a5f-c5767a074b95
