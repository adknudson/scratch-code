### A Pluto.jl notebook ###
# v0.11.14

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

# ╔═╡ d273e24e-dc3d-11ea-3505-451cee9a5677
using Distributions, StatsPlots

# ╔═╡ da6660d0-dc3d-11ea-2403-11c4e322a92d
begin
	μb_s = @bind μb html"<input type='range' min='-5' max='5' step='0.1' value='4.0'>"
	σb_s = @bind σb html"<input type='range' min='0' max='2' step='0.1' value='1.0'>"
	mb_s = @bind mb html"<input type='range' min='-1' max='1' step='0.1' value='0'>"
	sb_s = @bind sb html"<input type='range' min='0' max='1' step='0.025' value='0.1'>"
	n_s = @bind n html"<input type='range' min='1' max='3' step='0.5' value='1'>"
	
	md"""
	μb: $(μb_s)
	
	σb: $(σb_s)
	
	---
	
	mb: $(mb_s)
	
	sb: $(sb_s)
	
	---
	
	n: $(n_s)
	"""
end

# ╔═╡ f669e4f4-dc3e-11ea-3384-d3d68bd78db8
@show (μb = μb, σb = σb, mb = mb, sb = sb)

# ╔═╡ 78782c10-dc3e-11ea-39fb-b5df6027f052
function sample_delta(n, da, daG, daT, daTG, trt::Bool)
	S = rand(da, n) + rand(daG, n)
	if trt
		S += rand(daT, n) + rand(daTG, n)
	end
	return S
end

# ╔═╡ 7763bff8-dc3f-11ea-3f0c-2929bf0bbb0a
sample_delta(10, Normal(0, 1), Normal(0, 1), Normal(0, 1), Normal(0, 1), false)

# ╔═╡ 8e25fa30-dc3f-11ea-31aa-3ba18609064f


# ╔═╡ Cell order:
# ╠═d273e24e-dc3d-11ea-3505-451cee9a5677
# ╟─da6660d0-dc3d-11ea-2403-11c4e322a92d
# ╟─f669e4f4-dc3e-11ea-3384-d3d68bd78db8
# ╠═78782c10-dc3e-11ea-39fb-b5df6027f052
# ╠═7763bff8-dc3f-11ea-3f0c-2929bf0bbb0a
# ╠═8e25fa30-dc3f-11ea-31aa-3ba18609064f
