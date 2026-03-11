### A Pluto.jl notebook ###
# v0.20.24

using Markdown
using InteractiveUtils

# ╔═╡ 5d8b6933-6415-400b-b104-a73943767466
begin
	using Pkg
	Pkg.activate("..")
	Pkg.instantiate()
end

# ╔═╡ 1a55efd4-1d87-11f1-9ed7-8149f43b6dde
using Revise

# ╔═╡ 0bca0ba2-40d6-47fd-ad9e-0fae2444a5a9
using YagModel

# ╔═╡ 7750b49b-fc3b-4243-ac3d-48f59efc3e25
begin
	stride = 1000
	grid_size = (100, 100)
	block_size = map(s -> s ÷ 2, grid_size)
	disc = Discretization(1.0, 1.0, grid_size[2], grid_size[1])
	rp = ReactionParameters((15.0e-6, 15.0e-6, 15.0e-8), (-3.0, -5.0, 2.0), 146.0)
	ic_cfg = Checkerboard(
		disc.grid, 
		Size(block_size[2], block_size[1]), 
		(5.0e-6, 3.0e-6)
	)
	ic = build_ic(ic_cfg)
	ts = FixedStep(0.001)
	q0 = sum(ic[1] + ic[2])
	brake = RQTBrake(0.03, q0, stride)
	capture = StrideCapture(stride)
	
	io = open("solver_debug.log", "w")
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
	
	step = 13
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
capture.c1.size

# ╔═╡ Cell order:
# ╠═5d8b6933-6415-400b-b104-a73943767466
# ╠═1a55efd4-1d87-11f1-9ed7-8149f43b6dde
# ╠═0bca0ba2-40d6-47fd-ad9e-0fae2444a5a9
# ╠═7750b49b-fc3b-4243-ac3d-48f59efc3e25
# ╠═b2f39ca0-9fe5-41ea-888b-b2fec58d5726
# ╠═bdc6aac7-ee7c-4868-9f88-9a4e843ba55a
