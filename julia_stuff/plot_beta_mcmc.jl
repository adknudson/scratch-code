### A Pluto.jl notebook ###
# v0.11.2

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

# ╔═╡ 26710a2e-d366-11ea-2ec1-137b89d16053


# ╔═╡ f23a1aec-d361-11ea-0c4f-bb035fa3abe8
using Distributions, StatsPlots

# ╔═╡ 07df092a-d362-11ea-291a-4f0ef2df3347
function beta_s(w, a, b)
	return w.^(a - 1) .* (1 - w).^(b-1)
end

# ╔═╡ 2d699eb2-d362-11ea-03a8-45b1c4887aa4
beta_s(0.5, 4, 4)

# ╔═╡ 4eeb24fc-d362-11ea-0c64-b904d2e17b3e
random_coin(p) = rand() ≥ p ? false : true

# ╔═╡ 752a5a02-d362-11ea-3e9d-d945da3aa443
function beta_mcmc(iter, warm, a, b)
	cur = rand()
	for _ in 1:warm
		next = rand()
		accept_prob = min(beta_s(next, a, b) / beta_s(cur, a, b), 1.0)
		if random_coin(accept_prob)
			cur = next
		end
	end
	
	states = zeros(Float64, 0)
	for _ in 1:iter
		append!(states, cur)
		next = rand()
		accept_prob = min(beta_s(next, a, b) / beta_s(cur, a, b), 1.0)
		if random_coin(accept_prob)
			cur = next
		end
	end
	return states
end

# ╔═╡ c32d3764-d363-11ea-2566-a555643a18b7
beta_mcmc(1000, 100, 4, 96)

# ╔═╡ 580e8526-d365-11ea-199d-1f1b38d92e37
function plot_beta(n, a, b)
	histogram(beta_mcmc(n, 100, a, b), normalize=true, fill=(0, 0.5, :blue))
	plot!(Beta(a, b), fill=(0, .5,:orange))
end

# ╔═╡ 0e9bc9e2-d367-11ea-1660-41fad9e170a6
begin
	count_slider = @bind n html"<input type='range' min='10' max='100000' value='1000'>"
	successes_slider = @bind a html"<input type='range' min='0.1' max='10.0' step='0.1' value='2'>"
	failures_slider = @bind b html"<input type='range' min='0.1' max='10.0' step='0.1' value='5'>"
	
	md"""
	Num Samples: $(count_slider)
	
	Successes: $(successes_slider)
	
	Failures:  $(failures_slider)
	"""
end

# ╔═╡ 58842fc8-d366-11ea-29ff-c56e45e6fa80
plot_beta(n, a, b)

# ╔═╡ Cell order:
# ╠═f23a1aec-d361-11ea-0c4f-bb035fa3abe8
# ╠═07df092a-d362-11ea-291a-4f0ef2df3347
# ╠═2d699eb2-d362-11ea-03a8-45b1c4887aa4
# ╠═4eeb24fc-d362-11ea-0c64-b904d2e17b3e
# ╠═752a5a02-d362-11ea-3e9d-d945da3aa443
# ╠═c32d3764-d363-11ea-2566-a555643a18b7
# ╠═580e8526-d365-11ea-199d-1f1b38d92e37
# ╟─0e9bc9e2-d367-11ea-1660-41fad9e170a6
# ╟─58842fc8-d366-11ea-29ff-c56e45e6fa80
# ╠═26710a2e-d366-11ea-2ec1-137b89d16053
