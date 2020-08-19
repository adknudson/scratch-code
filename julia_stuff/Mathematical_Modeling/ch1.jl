### A Pluto.jl notebook ###
# v0.11.2

using Markdown
using InteractiveUtils

# ╔═╡ 211f4342-d69f-11ea-3e07-9d153fdb1c8b


# ╔═╡ f6dcb666-d69e-11ea-01ae-d13d004360ec


# ╔═╡ ed5a8c38-d69e-11ea-1a22-6ff1fdb45d33


# ╔═╡ e6bd3030-d69e-11ea-0cc4-5fb038e7b01e


# ╔═╡ 9c29eede-d69d-11ea-1a3e-114ddcb51f55
using Plots

# ╔═╡ b48ba866-d69d-11ea-3109-3f0153d18107
using Optim

# ╔═╡ 5d2f616a-d69c-11ea-229b-797ab47c6a86
pwd()

# ╔═╡ 8c6a0ef0-d69c-11ea-19c7-d9bbab40d4c5
import Pkg; Pkg.activate(".")

# ╔═╡ 7740c3d4-d69c-11ea-2abe-6b4b2855d51e
w(t) = 200 + 5t

# ╔═╡ ff5f02e4-d69c-11ea-2f8e-354630e5d9d1
p(t) = 0.65 - 0.01t

# ╔═╡ 0bbffd68-d69d-11ea-3aac-21137205aa47
C(t) = 0.45t

# ╔═╡ 1246313e-d69d-11ea-1a96-f1d25cad2805
R(t) = p(t) * w(t)

# ╔═╡ 1eca2d20-d69d-11ea-0fac-f19d684e247a
P(t) = R(t) - C(t)

# ╔═╡ adcd088a-d69d-11ea-172b-7193c836d4dc
plot(P, 0, 20)

# ╔═╡ 64635c14-d69e-11ea-0243-5d73df74a88f
lower = 0.0

# ╔═╡ a0d5d5e8-d69e-11ea-0a21-c14dbb276204
upper = Inf

# ╔═╡ a348aca6-d69e-11ea-01dd-4f67c29e2274
x0 = 7.5

# ╔═╡ 5ba3919c-d69e-11ea-008e-4f3adba84019
inner_optimizer = GradientDescent()

# ╔═╡ ba5b0312-d69e-11ea-1c17-278a5433feeb
results = optimize(P, lower, upper, x0, Fminbox(inner_optimizer))

# ╔═╡ Cell order:
# ╠═5d2f616a-d69c-11ea-229b-797ab47c6a86
# ╠═8c6a0ef0-d69c-11ea-19c7-d9bbab40d4c5
# ╠═7740c3d4-d69c-11ea-2abe-6b4b2855d51e
# ╠═ff5f02e4-d69c-11ea-2f8e-354630e5d9d1
# ╠═0bbffd68-d69d-11ea-3aac-21137205aa47
# ╠═1246313e-d69d-11ea-1a96-f1d25cad2805
# ╠═1eca2d20-d69d-11ea-0fac-f19d684e247a
# ╠═9c29eede-d69d-11ea-1a3e-114ddcb51f55
# ╠═adcd088a-d69d-11ea-172b-7193c836d4dc
# ╠═b48ba866-d69d-11ea-3109-3f0153d18107
# ╠═64635c14-d69e-11ea-0243-5d73df74a88f
# ╠═a0d5d5e8-d69e-11ea-0a21-c14dbb276204
# ╠═a348aca6-d69e-11ea-01dd-4f67c29e2274
# ╠═5ba3919c-d69e-11ea-008e-4f3adba84019
# ╠═ba5b0312-d69e-11ea-1c17-278a5433feeb
# ╠═211f4342-d69f-11ea-3e07-9d153fdb1c8b
# ╠═f6dcb666-d69e-11ea-01ae-d13d004360ec
# ╠═ed5a8c38-d69e-11ea-1a22-6ff1fdb45d33
# ╠═e6bd3030-d69e-11ea-0cc4-5fb038e7b01e
