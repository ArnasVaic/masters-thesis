### A Pluto.jl notebook ###
# v0.20.24

using Markdown
using InteractiveUtils

# ╔═╡ bca915c2-fbe7-4022-adfd-fe9913c73360
using Pkg

# ╔═╡ d242131b-5920-4253-bf20-553dcb0f3ee5
Pkg.add("CairoMakie")

# ╔═╡ 0eb867e8-bb86-43a2-9aed-1cff9b10f07c
push!(LOAD_PATH, abspath(joinpath(@__DIR__, "..", "..", "src")))

# ╔═╡ 1a55efd4-1d87-11f1-9ed7-8149f43b6dde
using Revise

# ╔═╡ 0bca0ba2-40d6-47fd-ad9e-0fae2444a5a9
using YagModel

# ╔═╡ 7750b49b-fc3b-4243-ac3d-48f59efc3e25
begin
	stride = 1000
	disc = Discretization(2, 20)
	rp = ReactionParameters(Val(1600))
	ic = build_checkerboard_ic(disc, 5.0e-6, 3.0e-6)
	ts = FixedStep(0.001) 
	brake = RQTBrake(0.03, sum(ic[1] + ic[2]), stride)
	capture = StrideCapture(stride, 1000, disc)
	
	io = open("debug.log", "w")
	logger = SimpleFileLogger(io)
	
	solver = ADISolver(disc, rp, ts, brake, capture, logger)
	
	solve(solver, ic)
end

# ╔═╡ bdc6aac7-ee7c-4868-9f88-9a4e843ba55a
begin
	using Plots
	using Printf
	using Measures

	gr()
	
	step = 3
	minval = 0
	maxval = maximum(ic[1])
	heatmap(capture.c1[step],
	    color=:viridis,
	    xlabel="x", ylabel="y",
	    title="c1 at step=$(step), time=$(round(capture.t[step], digits=2))",
		clim=(minval, maxval),
		size=(600, 600),
    	colorbar_ticks = [0, 5],
		margin=15mm
	)
end

# ╔═╡ b2f39ca0-9fe5-41ea-888b-b2fec58d5726
capture.len

# ╔═╡ Cell order:
# ╠═0eb867e8-bb86-43a2-9aed-1cff9b10f07c
# ╠═1a55efd4-1d87-11f1-9ed7-8149f43b6dde
# ╠═bca915c2-fbe7-4022-adfd-fe9913c73360
# ╠═0bca0ba2-40d6-47fd-ad9e-0fae2444a5a9
# ╠═7750b49b-fc3b-4243-ac3d-48f59efc3e25
# ╠═b2f39ca0-9fe5-41ea-888b-b2fec58d5726
# ╠═d242131b-5920-4253-bf20-553dcb0f3ee5
# ╠═bdc6aac7-ee7c-4868-9f88-9a4e843ba55a
