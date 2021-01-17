### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 8229b1a2-56b2-11eb-160f-ef3a879e6bc1
begin
	using MvSim, Distributions
	using QuadGK, HypergeometricFunctions
end

# ╔═╡ a4c4aa78-56b2-11eb-0d73-db4be7672174
D = NegativeBinomial(4, 0.2); G = GSDistribution(D)

# ╔═╡ e6ed3356-576c-11eb-086c-03056d38b755
begin
	function _beta_inc(z1::Float64, z2::Float64, a::Float64, b::Float64)
		inv(a) * (z2^a * _₂F₁(a,1-b,a+1,z2) - z1^a * _₂F₁(a,1-b,a+1,z1))
	end
	function _beta_inc(z1::Real, z2::Real, a::Real, b::Real)
		_beta_inc(Float64.((z1,z2,a,b))...)
	end
	_beta_inc(x::Real, a::Real, b::Real) = _beta_inc(0.0, x, a, b)
	_beta_inc(a::Real, b::Real) = _beta_inc(0.0, prevfloat(1.0), a, b)
end

# ╔═╡ e04cd4f6-576d-11eb-333c-b18d62949261
begin
	_q(p, F₀, x₀, α, g, k, γ) = x₀ + _beta_inc(F₀^k, p^k, (1-g)/k, 1-γ) / (α*k)
	_quantile(D::GSDistribution, p) = _q(p, D.F₀, D.x₀, D.α, D.g, D.k, D.γ)
end

# ╔═╡ 046f793c-5779-11eb-0cf9-995296e7ac25
function _moment(D::GSDistribution, j::Int=1)
	x₀ = D.x₀
	z1 = D.F₀^D.k
	a = (1 - D.g) / D.k
	b = 1 - D.γ
	c = inv(D.α * D.k)
	
	f = q -> (x₀ + c*_beta_inc(z1, q^D.k, a, b))^j
	quadgk(f, 0, 1, atol=1e-4)
end

# ╔═╡ 8d44f89e-5775-11eb-07d1-4d4eacb1d266
function _mean(D::GSDistribution)
	z1 = D.F₀^D.k
	a1 = (1 - D.g) / D.k
	b1 = 1 - D.γ
	a2 = (2 - D.g) / D.k
	b2 = 1 - D.γ
	D.x₀ + (_beta_inc(z1, prevfloat(1.0), a1, b1) - _beta_inc(a2, b2)) * inv(D.α * D.k)
end

# ╔═╡ 7d3bbe36-5777-11eb-3c48-814e063ec2ce
function _var(D::GSDistribution)
	m1 = _mean(G)
	m2 = _moment(D, 2)[1]
	m2 - m1^2
end

# ╔═╡ d7e1e7d6-577a-11eb-1fed-558c6e36fb63
_mean(G), mean(D)

# ╔═╡ 0dc63208-577b-11eb-1762-c57419afbff7
_var(G), var(D)

# ╔═╡ 1a1658ee-577b-11eb-1343-17c1b85a1730
_quantile(G, 0.7), quantile(D, 0.7)

# ╔═╡ 4267610a-577b-11eb-29cf-9fef7c2c8135
let x = rand(G, 1_000_000)
	mean(x), var(x), quantile(x, 0.7)
end

# ╔═╡ Cell order:
# ╠═8229b1a2-56b2-11eb-160f-ef3a879e6bc1
# ╠═a4c4aa78-56b2-11eb-0d73-db4be7672174
# ╠═e6ed3356-576c-11eb-086c-03056d38b755
# ╠═e04cd4f6-576d-11eb-333c-b18d62949261
# ╠═046f793c-5779-11eb-0cf9-995296e7ac25
# ╠═8d44f89e-5775-11eb-07d1-4d4eacb1d266
# ╠═7d3bbe36-5777-11eb-3c48-814e063ec2ce
# ╠═d7e1e7d6-577a-11eb-1fed-558c6e36fb63
# ╠═0dc63208-577b-11eb-1762-c57419afbff7
# ╠═1a1658ee-577b-11eb-1343-17c1b85a1730
# ╠═4267610a-577b-11eb-29cf-9fef7c2c8135
