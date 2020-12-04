### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# ╔═╡ 79fc34ca-2dde-11eb-3584-cb58edd3daf8
begin
	using Pkg
	Pkg.activate(".")
end

# ╔═╡ 9c48aa90-2dde-11eb-1e67-efc65d6f4be3
using Agents, Random, AgentsPlots, Plots

# ╔═╡ 3418fe6a-2de4-11eb-0e76-15abf2e4574c
using DrWatson: @dict

# ╔═╡ aed68560-2dde-11eb-31c9-23ad169c79fc
mutable struct Agent <: AbstractAgent
	id::Int
	pos::NTuple{2, Float64}
	vel::NTuple{2, Float64}
	mass::Float64
end

# ╔═╡ f299b3c6-2dde-11eb-16bd-af42ac6543d3
function ball_model(; speed = 0.002)
	space2d = ContinuousSpace(2; periodic = true, extend = (1, 1))
	model = ABM(Agent, space2d, properties = Dict(:dt => 1.0))
	
	for ind in 1:500
		pos = Tuple(rand(2))
		vel = sincos(2π * rand()) .* speed
		add_agent!(pos, model, vel, 1.0)
	end
	index!(model)
	return model
end

# ╔═╡ 581f4530-2ddf-11eb-38d9-f3e4f38c7cd1
model = ball_model()

# ╔═╡ 5c40ef1a-2ddf-11eb-3d89-ef0771f56142
agent_step!(agent, model) = move_agent!(agent, model, model.dt)

# ╔═╡ 755e5956-2ddf-11eb-1e70-c15532e49308
e = model.space.extend

# ╔═╡ 7bb75604-2ddf-11eb-2436-23c37d0229b6
anim = @animate for i in 1:2:100
	p1 = plotabm(
		model,
		as = 4,
		showaxis = false,
		grid = false,
		xlims = (0, e[1]),
		ylims = (0, e[2])
	)
	
	title!(p1, "step $(i)")
	step!(model, agent_step!, 2)
end

# ╔═╡ ba853824-2ddf-11eb-2bb0-253535c2dae6
gif(anim, "socialdist1.gif", fps = 25)

# ╔═╡ cb400f54-2ddf-11eb-0e07-a5323ada5f5e
function model_step!(model)
	for (a1, a2) in interacting_pairs(model, 0.012, :nearest)
		elastic_collision!(a1, a2, :mass)
	end
end

# ╔═╡ 181f99e0-2de0-11eb-2507-2969f580449d
model2 = ball_model()

# ╔═╡ 1fe6c1d8-2de0-11eb-2d48-63a43a9e0511
e2 = model.space.extend

# ╔═╡ 2a97e418-2de0-11eb-0f43-c90f9a98d5a4
anim2 = @animate for i in 1:2:1000
	p1 = plotabm(
		model2,
		as = 4,
		showaxis = false,
		grid = false,
		xlims = (0, e2[1]),
		ylims = (0, e2[2])
	)
	
	title!(p1, "step $(i)")
	step!(model2, agent_step!, model_step!, 2)
end

# ╔═╡ 70aa671e-2de0-11eb-1dcf-7d9e41b30d73
gif(anim2, "socialdist2.gif", fps=25)

# ╔═╡ 7dddad42-2de0-11eb-1b87-0fc3f6fb92b0
model3 = ball_model()

# ╔═╡ b277f5a6-2de2-11eb-0ae4-833c71e12a1d
for id in 1:400
	agent = model3[id]
	agent.mass = Inf
	agent.vel = (0.0, 0.0)
end

# ╔═╡ 1d5a7542-2de0-11eb-1ae3-9d47cf641797
e3 = model.space.extend

# ╔═╡ cf7d3dca-2de2-11eb-03b4-2f1701a736be
anim3 = @animate for i in 1:2:1000
    p1 = plotabm(
        model3,
        as = 4,
        showaxis = false,
        grid = false,
        xlims = (0, e3[1]),
        ylims = (0, e3[2]),
    )
    title!(p1, "step $(i)")
    step!(model3, agent_step!, model_step!, 2)
end

# ╔═╡ de0a42d2-2de2-11eb-0adb-ff14a9c1d144
gif(anim3, "socialdist3.gif", fps = 25)

# ╔═╡ f7816894-2de2-11eb-26ad-b38c50b15502
mutable struct PoorSoul <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64}
    vel::NTuple{2,Float64}
    mass::Float64
    days_infected::Int  # number of days since is infected
    status::Symbol  # :S, :I or :R
    β::Float64
end

# ╔═╡ 2bc54854-2de4-11eb-0be3-e7bbad90f756
const steps_per_day = 24

# ╔═╡ 5bd35cd4-2de4-11eb-032f-33a9b9a64318
function sir_initiation(;
		infection_period = 30 * steps_per_day,
		detection_time = 14 * steps_per_day,
		reinfection_probability = 0.05,
		isolated = 0.0,
		interaction_radius = 0.012,
		dt = 1.0,
		speed = 0.002,
		death_rate = 0.044,
		N = 1000,
		initial_infected = 5,
		seed = 42,
		βmin = 0.4,
		βmax = 0.8,
)
	properties = @dict(
		infection_period,
		reinfection_probability,
		detection_time,
		death_rate,
		interaction_radius,
		dt,
	)
	
	space = ContinuousSpace(2)
	model = ABM(PoorSoul, space, properties = properties)
	
	Random.seed!(seed)
	for ind in 1:N
		pos = Tuple(rand(2))
		status = ind ≤ N - initial_infected ? :S : :I
		isisolated = ind ≤ isolated * N
		mass = isisolated ? Inf : 1.0
		vel = isisolated ? (0.0, 0.0) : sincos(2π * rand()) .* speed
		
		β = (βmax - βmin) * rand() + βmin
		add_agent!(pos, model, vel, mass, 0, status, β)
	end
	
	Agents.index!(model)
	return model
end

# ╔═╡ 1dab0fc2-2de6-11eb-3691-597e0956fbd3
sir_model = sir_initiation()

# ╔═╡ 271c4670-2de6-11eb-0388-979727b20fc4
sir_colors(a) = a.status == :S ? "#2b2b33" : a.status == :I ? "#bf2642" : "#338c54"

# ╔═╡ 2d0fbf80-2de6-11eb-15a6-5f226844b4cd
e4 = model.space.extend

# ╔═╡ 3425c292-2de6-11eb-1c3f-c93795c89eca
plotabm(
    sir_model;
    ac = sir_colors,
    as = 4,
    msc=:auto,
    showaxis = false,
    grid = false,
    xlims = (0, e4[1]),
    ylims = (0, e4[2]),
)

# ╔═╡ 3fbf7e86-2de6-11eb-0f68-d16808c19ad4
function transmit!(a1, a2, rp)
    # for transmission, only 1 can have the disease (otherwise nothing happens)
    count(a.status == :I for a in (a1, a2)) ≠ 1 && return
    infected, healthy = a1.status == :I ? (a1, a2) : (a2, a1)

    rand() > infected.β && return

    if healthy.status == :R
        rand() > rp && return
    end
    healthy.status = :I
end

# ╔═╡ f33fe392-2de6-11eb-1956-c1094216d0e5
function sir_model_step!(model)
    r = model.interaction_radius
    for (a1, a2) in interacting_pairs(model, r, :nearest)
        transmit!(a1, a2, model.reinfection_probability)
        elastic_collision!(a1, a2, :mass)
    end
end

# ╔═╡ 10db19ee-2de7-11eb-027b-d996dddf825b
update!(agent) = agent.status == :I && (agent.days_infected += 1)

# ╔═╡ 13ed3cc0-2de7-11eb-3873-f751fef13f8f
function recover_or_die!(agent, model)
    if agent.days_infected ≥ model.infection_period
        if rand() ≤ model.death_rate
            kill_agent!(agent, model)
        else
            agent.status = :R
            agent.days_infected = 0
        end
    end
end

# ╔═╡ 01f5b4ac-2de7-11eb-19fb-63c51cc89c14
function sir_agent_step!(agent, model)
    move_agent!(agent, model, model.dt)
    update!(agent)
    recover_or_die!(agent, model)
end

# ╔═╡ 1e8a8d5e-2de7-11eb-2b15-dfcb7f852dce
sir_model2 = sir_initiation()

# ╔═╡ 302ebe72-2de7-11eb-0c64-9d26a598a2b8
e5 = model.space.extend

# ╔═╡ 3a6fac16-2de7-11eb-369f-81b27d19c918
anim5 = @animate for i in 1:2:1000
    p1 = plotabm(
        sir_model2;
        ac = sir_colors,
        as = 4,
        msc=:auto,
        showaxis = false,
        grid = false,
        xlims = (0, e5[1]),
        ylims = (0, e5[2]),
    )
    title!(p1, "step $(i)")
    step!(sir_model2, sir_agent_step!, sir_model_step!, 2)
end

# ╔═╡ 45b5c632-2de7-11eb-16eb-8b5a9b677120
gif(anim5, "socialdist4.gif", fps = 15)

# ╔═╡ 4c0b9a34-2de7-11eb-3cc1-d58ec6476273
begin
	infected(x) = count(i == :I for i in x)
	recovered(x) = count(r == :R for r in x)
	adata = [(:status, infected), (:status, recovered)]
end

# ╔═╡ 9683cf54-2de8-11eb-0bbd-49bbf69b2f2e
begin
	r1, r2 = 0.04, 0.33
	β1, β2 = 0.5, 0.1
	sir_model3 = sir_initiation(reinfection_probability = r1, βmin = β1)
	sir_model4 = sir_initiation(reinfection_probability = r2, βmin = β1)
	sir_model5 = sir_initiation(reinfection_probability = r1, βmin = β2)
end

# ╔═╡ afebab10-2de8-11eb-30f8-f1c09ac25b23
begin
	data1, _ = run!(sir_model3, sir_agent_step!, sir_model_step!, 2000; adata = adata)
	data2, _ = run!(sir_model4, sir_agent_step!, sir_model_step!, 2000; adata = adata)
	data3, _ = run!(sir_model5, sir_agent_step!, sir_model_step!, 2000; adata = adata)
end

# ╔═╡ bc35595e-2de8-11eb-25dc-e9800d9740a5
data1[(end - 10):end, :]

# ╔═╡ a9f1ef9e-2de8-11eb-1e74-d77adafeb96c
begin
	p = plot(
		data1[:, aggname(:status, infected)],
		label = "r=$r1, beta=$β1",
		ylabel = "Infected",
	)
	plot!(p, data2[:, aggname(:status, infected)], label = "r=$r2, beta=$β1")
	plot!(p, data3[:, aggname(:status, infected)], label = "r=$r1, beta=$β2")
end

# ╔═╡ 0ded66cc-2de9-11eb-1f0f-e17e2a412fde
sir_model6 = sir_initiation(isolated = 0.8)

# ╔═╡ aba6890c-2de9-11eb-38b6-6f1e6c5ccb2e
e6 = model.space.extend

# ╔═╡ b09ece88-2de9-11eb-0db4-35cf10abd260
anim6 = @animate for i in 0:2:1000
    p1 = plotabm(
        sir_model6;
        ac = sir_colors,
        as = 4,
        msc=:auto,
        showaxis = false,
        grid = false,
        xlims = (0, e6[1]),
        ylims = (0, e6[2]),
    )
    title!(p1, "step $(i)")
    step!(sir_model6, sir_agent_step!, sir_model_step!, 2)
end

# ╔═╡ c069febe-2de9-11eb-19de-47a11feb60cf
gif(anim6, "socialdist5.gif", fps = 20)

# ╔═╡ dcc4c5a8-2de9-11eb-1c21-e39ce7354abd
begin
	r4 = 0.04
	sir_model7 = sir_initiation(reinfection_probability = r4, βmin = β1, isolated = 0.8)
	data4, _1 = run!(sir_model7, sir_agent_step!, sir_model_step!, 2000; adata = adata)
end

# ╔═╡ f0e2019a-2de9-11eb-0215-53c654834536
plot!(p, data4[:, aggname(:status, infected)], label = "r=$r4, social distancing")

# ╔═╡ 0d661664-2dea-11eb-02e7-5d3831d1f8b1


# ╔═╡ Cell order:
# ╠═79fc34ca-2dde-11eb-3584-cb58edd3daf8
# ╠═9c48aa90-2dde-11eb-1e67-efc65d6f4be3
# ╠═aed68560-2dde-11eb-31c9-23ad169c79fc
# ╠═f299b3c6-2dde-11eb-16bd-af42ac6543d3
# ╠═581f4530-2ddf-11eb-38d9-f3e4f38c7cd1
# ╠═5c40ef1a-2ddf-11eb-3d89-ef0771f56142
# ╠═755e5956-2ddf-11eb-1e70-c15532e49308
# ╠═7bb75604-2ddf-11eb-2436-23c37d0229b6
# ╠═ba853824-2ddf-11eb-2bb0-253535c2dae6
# ╠═cb400f54-2ddf-11eb-0e07-a5323ada5f5e
# ╠═181f99e0-2de0-11eb-2507-2969f580449d
# ╠═1fe6c1d8-2de0-11eb-2d48-63a43a9e0511
# ╟─2a97e418-2de0-11eb-0f43-c90f9a98d5a4
# ╟─70aa671e-2de0-11eb-1dcf-7d9e41b30d73
# ╠═7dddad42-2de0-11eb-1b87-0fc3f6fb92b0
# ╠═b277f5a6-2de2-11eb-0ae4-833c71e12a1d
# ╠═1d5a7542-2de0-11eb-1ae3-9d47cf641797
# ╠═cf7d3dca-2de2-11eb-03b4-2f1701a736be
# ╠═de0a42d2-2de2-11eb-0adb-ff14a9c1d144
# ╠═f7816894-2de2-11eb-26ad-b38c50b15502
# ╠═2bc54854-2de4-11eb-0be3-e7bbad90f756
# ╠═3418fe6a-2de4-11eb-0e76-15abf2e4574c
# ╠═5bd35cd4-2de4-11eb-032f-33a9b9a64318
# ╠═1dab0fc2-2de6-11eb-3691-597e0956fbd3
# ╠═271c4670-2de6-11eb-0388-979727b20fc4
# ╠═2d0fbf80-2de6-11eb-15a6-5f226844b4cd
# ╠═3425c292-2de6-11eb-1c3f-c93795c89eca
# ╠═3fbf7e86-2de6-11eb-0f68-d16808c19ad4
# ╠═f33fe392-2de6-11eb-1956-c1094216d0e5
# ╠═01f5b4ac-2de7-11eb-19fb-63c51cc89c14
# ╠═10db19ee-2de7-11eb-027b-d996dddf825b
# ╠═13ed3cc0-2de7-11eb-3873-f751fef13f8f
# ╠═1e8a8d5e-2de7-11eb-2b15-dfcb7f852dce
# ╠═302ebe72-2de7-11eb-0c64-9d26a598a2b8
# ╟─3a6fac16-2de7-11eb-369f-81b27d19c918
# ╠═45b5c632-2de7-11eb-16eb-8b5a9b677120
# ╠═4c0b9a34-2de7-11eb-3cc1-d58ec6476273
# ╠═9683cf54-2de8-11eb-0bbd-49bbf69b2f2e
# ╠═afebab10-2de8-11eb-30f8-f1c09ac25b23
# ╠═bc35595e-2de8-11eb-25dc-e9800d9740a5
# ╟─a9f1ef9e-2de8-11eb-1e74-d77adafeb96c
# ╠═0ded66cc-2de9-11eb-1f0f-e17e2a412fde
# ╠═aba6890c-2de9-11eb-38b6-6f1e6c5ccb2e
# ╠═b09ece88-2de9-11eb-0db4-35cf10abd260
# ╠═c069febe-2de9-11eb-19de-47a11feb60cf
# ╠═dcc4c5a8-2de9-11eb-1c21-e39ce7354abd
# ╠═f0e2019a-2de9-11eb-0215-53c654834536
# ╠═0d661664-2dea-11eb-02e7-5d3831d1f8b1
