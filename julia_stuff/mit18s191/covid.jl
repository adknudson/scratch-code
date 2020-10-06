### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 2af8f902-04db-11eb-1bb8-69d278699396
begin
	using Pkg
	Pkg.activate(".")
	Pkg.add.(["CSV", "DataFrames", "PlutoUI", "Shapefile", "ZipFile", "LsqFit"])
	
	using CSV, DataFrames, PlutoUI, Shapefile, ZipFile, LsqFit, Plots
end

# ╔═╡ b9d67164-04da-11eb-3ddb-15decc3777de
md"""
# Module 2
"""

# ╔═╡ 3a7ce50a-04db-11eb-0141-a5bda7d3df77
pwd()

# ╔═╡ c5d6d3a8-04da-11eb-0681-3bfc371d1193
url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv";

# ╔═╡ 2e2edb82-04db-11eb-2e20-95b8133ba194
download(url, "covid_data.csv");

# ╔═╡ 045e6290-04dc-11eb-2ef0-6172636a822a
df = DataFrame(CSV.File("covid_data.csv"))

# ╔═╡ df9ee51e-04dc-11eb-3353-a55f3e3d8ab4
US_row = findfirst(df["Country/Region"] .== "US")

# ╔═╡ cc019670-04dd-11eb-086f-f979907b2be1
df[US_row,5:end]

# ╔═╡ 09a88ea0-04dd-11eb-1123-61a3c396159e
point_nemo = findall((df["Lat"] .≈ 0) .& (df["Long"] .≈ 0))

# ╔═╡ 86b1e21a-04de-11eb-1c90-1146b91b8a95
df[point_nemo,1:2]

# ╔═╡ 8b8db304-04de-11eb-08ff-316a877d956a
@code_lowered 1:5

# ╔═╡ e8083dc0-04e3-11eb-34c2-d52c990bed35


# ╔═╡ Cell order:
# ╟─b9d67164-04da-11eb-3ddb-15decc3777de
# ╠═3a7ce50a-04db-11eb-0141-a5bda7d3df77
# ╠═c5d6d3a8-04da-11eb-0681-3bfc371d1193
# ╠═2e2edb82-04db-11eb-2e20-95b8133ba194
# ╠═2af8f902-04db-11eb-1bb8-69d278699396
# ╠═045e6290-04dc-11eb-2ef0-6172636a822a
# ╠═df9ee51e-04dc-11eb-3353-a55f3e3d8ab4
# ╠═cc019670-04dd-11eb-086f-f979907b2be1
# ╠═09a88ea0-04dd-11eb-1123-61a3c396159e
# ╠═86b1e21a-04de-11eb-1c90-1146b91b8a95
# ╠═8b8db304-04de-11eb-08ff-316a877d956a
# ╠═e8083dc0-04e3-11eb-34c2-d52c990bed35
