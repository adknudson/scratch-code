### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 46811f2c-8368-11eb-0e56-759b768b82a8
begin
	using StatsPlots, Distributions
	using PlutoUI, Printf
end

# ╔═╡ 315f2b82-8368-11eb-09bf-efaba7656ddc
md"""
# Gamma Distribution

Set the desired mean and standard deviation of the Gamma distribution:
"""

# ╔═╡ c6334fae-8365-11eb-2b79-61c202eb0c43
md"""
μ $(@bind μ Slider(1000:1:10000, default=5000, show_value=true))

σ $(@bind σ Slider(1000:1:5000, default=1000, show_value=true))
"""

# ╔═╡ 51d18fe2-8368-11eb-3739-6950b3621b98
md"""
The corresponding shape and scale parameters are:
"""

# ╔═╡ 71567974-8366-11eb-35b2-9f6c6e9dfe37
begin
	α, θ = (μ/σ)^2, σ^2/μ
	(α=α, θ=θ)
end

# ╔═╡ 9baec260-8368-11eb-3929-2d12cbbbf4e1
md"""
The corresponding rate is
"""

# ╔═╡ 069cfee8-8367-11eb-2c2e-41b1a232e8eb
β = 1/θ

# ╔═╡ a7f5ec4c-8368-11eb-2f9f-07a33eeb307c
md"""
Define a Gamma distribution in Julia with the shape/scale parameters
"""

# ╔═╡ 2adec62e-8364-11eb-04dd-dff15ba3efa2
G = Gamma(α, θ)

# ╔═╡ bc80c63c-8368-11eb-3489-d38141d084b4
md"""
Finally, plot the Gamma distribution
"""

# ╔═╡ 17247aaa-8364-11eb-387b-67be3fd9fa82
plot(G, func=pdf, xlims=(0,quantile(G, 0.9999)),
     legend=false, 
	 title=@sprintf("Gamma(α=%.4f, β=%.4f)", G.α, β))

# ╔═╡ Cell order:
# ╟─46811f2c-8368-11eb-0e56-759b768b82a8
# ╟─315f2b82-8368-11eb-09bf-efaba7656ddc
# ╟─c6334fae-8365-11eb-2b79-61c202eb0c43
# ╟─51d18fe2-8368-11eb-3739-6950b3621b98
# ╟─71567974-8366-11eb-35b2-9f6c6e9dfe37
# ╟─9baec260-8368-11eb-3929-2d12cbbbf4e1
# ╟─069cfee8-8367-11eb-2c2e-41b1a232e8eb
# ╟─a7f5ec4c-8368-11eb-2f9f-07a33eeb307c
# ╟─2adec62e-8364-11eb-04dd-dff15ba3efa2
# ╟─bc80c63c-8368-11eb-3489-d38141d084b4
# ╟─17247aaa-8364-11eb-387b-67be3fd9fa82
