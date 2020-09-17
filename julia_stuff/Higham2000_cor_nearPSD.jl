### A Pluto.jl notebook ###
# v0.11.2

using Markdown
using InteractiveUtils

# ╔═╡ 57c2a9d4-f715-11ea-3899-41b73d49f3aa


# ╔═╡ 75b58d0e-f70c-11ea-14f8-097663f86624
using LinearAlgebra

# ╔═╡ 27699ed2-f715-11ea-175d-85a915672158
push!(LOAD_PATH, "/home/alex/.julia/dev/BFloat")

# ╔═╡ c5e773d0-f70c-11ea-0e48-41c25a481ff0
X = Float16[ 2 -1  0  0
	        -1  2 -1  0
	         0 -1  2 -1
	         0  0 -1 2]

# ╔═╡ 7e41d0de-f70c-11ea-13dc-75b27911e55a
function getAplus(A::Matrix{T}) where {T<:AbstractFloat}
	λ, Q = eigen(A)
	Λ = diagm(max.(λ, 0))
	Q * Λ * Q'
end

# ╔═╡ 5e47f6ae-f70d-11ea-0906-71c483a911e2
function getPs(A::Matrix{T}, W::Matrix{T}) where {T<:AbstractFloat}
	W½ = sqrt(W)
	W½ * getAplus(W½ * A * W½) * W½
end

# ╔═╡ 58cb96a6-f70e-11ea-0470-330ce574ed07
function getPu(A::Matrix{T}, W::Matrix{T}) where {T<:AbstractFloat}
	_A = copy(A)
	_A[W .> 0] .= W[W .> 0]
	_A
end

# ╔═╡ b78e4438-f70e-11ea-3b6f-89b5be33ee11
function cor_nearPSD(A::Matrix{T}; n_iter::Int=10) where {T<:AbstractFloat}
	n = size(A, 1)
	W = Matrix{T}(I, n, n)
	Yₖ = copy(A)
	δₛ = zeros(T, n, n)
	Rₖ = Matrix{T}(undef, n, n)
	Xₖ = Matrix{T}(undef, n, n)
	for k = 1:n_iter
		Rₖ .= Yₖ .- δₛ
		Xₖ .= getPs(Rₖ, W)
		δₛ .= Xₖ .- Rₖ
		Yₖ .= getPu(Xₖ, W)
	end
	Yₖ
end

# ╔═╡ 42eb1dc8-f710-11ea-0680-ef54bad681fe
cor_nearPSD(X; n_iter=5)

# ╔═╡ efd3f0de-f710-11ea-0ad3-dbb5bde0455e
cor_nearPSD(X)

# ╔═╡ f5fe64f8-f710-11ea-345a-835df50862cc
cor_nearPSD(X; n_iter=100)

# ╔═╡ e0a30670-f712-11ea-24ba-596b1848db8d
cor_nearPSD(X; n_iter=1000)

# ╔═╡ Cell order:
# ╠═27699ed2-f715-11ea-175d-85a915672158
# ╠═75b58d0e-f70c-11ea-14f8-097663f86624
# ╠═57c2a9d4-f715-11ea-3899-41b73d49f3aa
# ╠═c5e773d0-f70c-11ea-0e48-41c25a481ff0
# ╠═7e41d0de-f70c-11ea-13dc-75b27911e55a
# ╠═5e47f6ae-f70d-11ea-0906-71c483a911e2
# ╠═58cb96a6-f70e-11ea-0470-330ce574ed07
# ╠═b78e4438-f70e-11ea-3b6f-89b5be33ee11
# ╠═42eb1dc8-f710-11ea-0680-ef54bad681fe
# ╠═efd3f0de-f710-11ea-0ad3-dbb5bde0455e
# ╠═f5fe64f8-f710-11ea-345a-835df50862cc
# ╠═e0a30670-f712-11ea-24ba-596b1848db8d
