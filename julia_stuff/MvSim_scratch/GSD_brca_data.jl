### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ e40e2456-5796-11eb-3912-49017d5220e0
using MvSim, Distributions, JLD

# ╔═╡ 82b7dee0-5799-11eb-28c7-351c38a3f2b4
using LsqFit

# ╔═╡ bdc7625e-57c0-11eb-24f3-511cbba71045
using StatsPlots

# ╔═╡ cda13dde-5796-11eb-2a83-dfdf197cfc18
md"""# BRCA Data"""

# ╔═╡ 1400dfee-5797-11eb-21e3-1bc60b4b9caf
begin
	tmp_dir = mktempdir()
	tarball = "data/brca200.tar.xz"
	run(`tar -xf $tarball -C $tmp_dir`)
	brca = JLD.load(joinpath(tmp_dir, "brca200.jld"), "brca200")
end

# ╔═╡ 6bddede2-5797-11eb-3f70-7bd6901b8822
function fit_mom(x)
    μ = mean(x)
    σ = std(x)
    r = μ^2 / (σ^2 - μ)
    p = μ / σ^2
    NegativeBinomial(r, p)
end

# ╔═╡ 70d5dc4c-5797-11eb-14b2-339958311b90
margins = [fit_mom(x) for x in eachcol(brca)];

# ╔═╡ 743b902a-5797-11eb-1d78-9da56692b752
begin
	unencoded = Vector{Int}()
	println("Starting journey of encoding")
	for (i, m) in enumerate(margins)
		try
			GSDistribution(m, n=101)
		catch y
			if isa(y, DomainError)
				push!(unencoded, i)
				@show i
				continue
			end
		end
	end
	println("End of journey")
end

# ╔═╡ c8d44218-579b-11eb-3652-810ab6ce3ba9
encoded = setdiff(1:200, unencoded);

# ╔═╡ f8f01f76-579b-11eb-3d81-cd5ed7d8aa9a
GSD_margins = [GSDistribution(margins[i], n=101) for i in encoded];

# ╔═╡ 1f606fd0-579c-11eb-30ad-413141a9cb4f
ρ = cor(brca[:,encoded], Pearson)

# ╔═╡ 2f93a4e4-579c-11eb-0760-679147b4ec98
B = MvDistribution(ρ, GSD_margins, Pearson)

# ╔═╡ 6b0c00d8-579d-11eb-3f20-4b65cb45fafb
# B2 = pearson_match(B)

# ╔═╡ a61b721c-579d-11eb-0870-97cbfe5fefd6
md"""## Scaling the input data"""

# ╔═╡ 3cab9794-57c0-11eb-3936-f1291bb2f9bf
x₀ = [quantile(x, 0.00001) for x in eachcol(brca)]

# ╔═╡ 5272b9a4-57c0-11eb-15e4-8722662ad975
brca_y = brca ./ x₀'

# ╔═╡ 8c70ece8-57c0-11eb-0b99-6395ea84f11e
let y = brca_y[:,1]
	μ = mean(y)
    σ = std(y)
    r = μ^2 / (σ^2 - μ)
    p = μ / σ^2
	(μ, σ, r, p)
end

# ╔═╡ e9e288ea-57c1-11eb-371e-0959cf006c34
begin
	unfit = Vector{Int}()
	println("Starting journey of fitting")
	for (i, m) in enumerate(eachcol(brca_y))
		try
			fit_mom(m)
		catch y
			if isa(y, ArgumentError)
				push!(unfit, i)
				@show i
				continue
			end
		end
	end
	println("End of journey")
end

# ╔═╡ 5076a66e-57c1-11eb-3efe-a7b8122f6a8c
let k = 1
	histogram(brca_y[:,k], bins=50, normalize=true)
	plot!(fit_mle(Gamma, brca_y[:,k]))
end

# ╔═╡ a310c1c0-57c1-11eb-3056-1155615333fd
margins_y = [fit_mle(Gamma, y) for y in eachcol(brca_y)]

# ╔═╡ da48e08c-57c4-11eb-01e7-51b2c8b4b76e
margins_x = [fit_mle(Gamma, y) for y in eachcol(brca)]

# ╔═╡ 99d85c06-57c3-11eb-1e7d-a75426f4a839
median(margins_y[1])

# ╔═╡ c017ac68-57c2-11eb-2fa7-2d372f9c1346
let k = 78, q = 0.345
	quantile(margins_y[k], q) * x₀[k], quantile(brca[:,k], q)
end

# ╔═╡ c45c9d4c-57c4-11eb-0b23-654c162062d0
pearson_bounds(margins_y[1], margins_y[1])

# ╔═╡ e0832162-57c4-11eb-3250-a949663b5096
pearson_bounds(margins_x[1], margins_x[1])

# ╔═╡ 01277486-57c5-11eb-14b9-232538f4fb5a
pearson_bounds(GSD_margins[1], GSD_margins[1])

# ╔═╡ Cell order:
# ╟─cda13dde-5796-11eb-2a83-dfdf197cfc18
# ╠═e40e2456-5796-11eb-3912-49017d5220e0
# ╠═82b7dee0-5799-11eb-28c7-351c38a3f2b4
# ╠═1400dfee-5797-11eb-21e3-1bc60b4b9caf
# ╠═6bddede2-5797-11eb-3f70-7bd6901b8822
# ╠═70d5dc4c-5797-11eb-14b2-339958311b90
# ╠═743b902a-5797-11eb-1d78-9da56692b752
# ╠═c8d44218-579b-11eb-3652-810ab6ce3ba9
# ╠═f8f01f76-579b-11eb-3d81-cd5ed7d8aa9a
# ╠═1f606fd0-579c-11eb-30ad-413141a9cb4f
# ╠═2f93a4e4-579c-11eb-0760-679147b4ec98
# ╠═6b0c00d8-579d-11eb-3f20-4b65cb45fafb
# ╟─a61b721c-579d-11eb-0870-97cbfe5fefd6
# ╠═3cab9794-57c0-11eb-3936-f1291bb2f9bf
# ╠═5272b9a4-57c0-11eb-15e4-8722662ad975
# ╠═8c70ece8-57c0-11eb-0b99-6395ea84f11e
# ╠═e9e288ea-57c1-11eb-371e-0959cf006c34
# ╠═bdc7625e-57c0-11eb-24f3-511cbba71045
# ╠═5076a66e-57c1-11eb-3efe-a7b8122f6a8c
# ╠═a310c1c0-57c1-11eb-3056-1155615333fd
# ╠═da48e08c-57c4-11eb-01e7-51b2c8b4b76e
# ╠═99d85c06-57c3-11eb-1e7d-a75426f4a839
# ╠═c017ac68-57c2-11eb-2fa7-2d372f9c1346
# ╠═c45c9d4c-57c4-11eb-0b23-654c162062d0
# ╠═e0832162-57c4-11eb-3250-a949663b5096
# ╠═01277486-57c5-11eb-14b9-232538f4fb5a
