### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ 6d936380-0e93-11eb-2542-15cbc4d02074
using CSV, DataFrames

# ╔═╡ 8617e282-0e93-11eb-0b11-c556f9ee135f
df = DataFrame(CSV.File("/home/alex/Downloads/bound_comparison.csv"))

# ╔═╡ dedb2cdc-0e96-11eb-0983-11e03d40e585
begin
	df[!, :q] = convert.(Int, df[:, :q])
	df[!, :n] = convert.(Int, df[:, :n])
	df[!, :d] = convert.(Int, df[:, :d])
end

# ╔═╡ f7fb9f62-0e96-11eb-2c34-079bd270b54d
df

# ╔═╡ 9875d330-0e93-11eb-3607-95bdd764ad95
__spheres(q::Int, n::Int, d::Int) = sum([(q - 1)^i * binomial(n, i) for i ∈ 0:d])

# ╔═╡ a6b2bc2c-0e93-11eb-00b6-a9c163816fa5
__sphere_bound(q::Int, n::Int, d::Int) = q^n / __spheres(q, n, d)

# ╔═╡ aa749704-0e93-11eb-00f6-97f13830be54
sphere_packing_bound(q::Int, n::Int, d::Int) = __sphere_bound(q, n, floor(Int, (d - 1) / 2))

# ╔═╡ ae3cedb6-0e93-11eb-2ebb-91f55792e5fc
hamming_bound(q::Int, n::Int, d::Int) = sphere_packing_bound(q, n, d)

# ╔═╡ b32ed9b0-0e93-11eb-3cb5-2d44a475d2e9
begin
	xs = range(extrema(df.q)...; step=1);
	ys = range(extrema(df.n)...; step=1);
	zs = range(extrema(df.d)...; step=1);
end

# ╔═╡ ff0ef2c8-0e95-11eb-21b7-3529ae19177d
xyz = reshape(collect(Iterators.product(xs, ys, zs)), 1, :)

# ╔═╡ e0547b6a-0e94-11eb-1be4-035cd149e7f5
H = dropdims([hamming_bound(v...) for v in xyz]; dims=1)

# ╔═╡ df22d9ae-0e98-11eb-0f5a-796db6aae952
begin
	q = dropdims(getindex.(xyz, 1); dims=1)
	n = dropdims(getindex.(xyz, 2); dims=1)
	d = dropdims(getindex.(xyz, 3); dims=1)
end

# ╔═╡ 773939c2-0e99-11eb-0cd8-23564be03679


# ╔═╡ Cell order:
# ╠═6d936380-0e93-11eb-2542-15cbc4d02074
# ╠═8617e282-0e93-11eb-0b11-c556f9ee135f
# ╠═dedb2cdc-0e96-11eb-0983-11e03d40e585
# ╠═f7fb9f62-0e96-11eb-2c34-079bd270b54d
# ╠═9875d330-0e93-11eb-3607-95bdd764ad95
# ╠═a6b2bc2c-0e93-11eb-00b6-a9c163816fa5
# ╠═aa749704-0e93-11eb-00f6-97f13830be54
# ╠═ae3cedb6-0e93-11eb-2ebb-91f55792e5fc
# ╠═b32ed9b0-0e93-11eb-3cb5-2d44a475d2e9
# ╠═ff0ef2c8-0e95-11eb-21b7-3529ae19177d
# ╠═e0547b6a-0e94-11eb-1be4-035cd149e7f5
# ╠═df22d9ae-0e98-11eb-0f5a-796db6aae952
# ╠═773939c2-0e99-11eb-0cd8-23564be03679
