### A Pluto.jl notebook ###
# v0.20.24

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 1b770759-4ef2-4e6c-915f-705e78b52c65
using Pkg

# ╔═╡ 338884f6-b349-4301-97a8-fb225bfb44e3
Pkg.activate("../..")

# ╔═╡ 1a55efd4-1d87-11f1-9ed7-8149f43b6dde
using Revise

# ╔═╡ b363f928-c52a-4555-99f4-5ff1e29a64d6
using PlutoUI

# ╔═╡ 0bca0ba2-40d6-47fd-ad9e-0fae2444a5a9
using YagModel

# ╔═╡ d07779a3-2b88-47ca-a47b-ed97a29c4154
using JLD2

# ╔═╡ 82f06035-70aa-4eac-a40c-525f11e79f4c
using CairoMakie

# ╔═╡ 0541bc9d-128d-4b96-a45e-d53208c2842a
stride = 1000 # match capture and brake stride to capture final frame

# ╔═╡ 232f1643-db37-4b93-b27c-4b1315ffa61a
disc = Discretization(2, 20) # particles, particle resolution

# ╔═╡ 2acf9199-abe1-4fd9-8110-d8932dec009d
rp = ReactionParameters(Val(1600))

# ╔═╡ 6fed4699-655c-4361-ad72-c8355c928ece
ic = build_checkerboard_ic(disc, 5.0e-6, 3.0e-6)

# ╔═╡ e51a9e75-cf96-4a9e-ab01-f8727d9bca2a
ts = FixedStep(0.001) 

# ╔═╡ 43042319-c6a6-4425-b891-33010ab2d691
brake = RQTBrake(0.03, sum(ic[1] + ic[2]), stride)

# ╔═╡ 5f2e679a-ebc4-4b3b-999c-69333611ba00
capture = StrideCapture(stride, 1000, disc)

# ╔═╡ 6e2f7e0b-006d-498d-a325-f55cf4cbf3b1
io = open("debug.log", "w")

# ╔═╡ b1b9fe2a-d1aa-4709-b674-83654912d835
logger = SimpleFileLogger(io)

# ╔═╡ 16bca95f-5570-4cb1-8789-9f2f1023fe4d
solver = ADISolver(disc, rp, ts, brake, capture, logger)

# ╔═╡ deb90105-cb3c-4868-bf52-3e8e7bc32c27
@bind run_solver PlutoUI.Button("Run Solver")

# ╔═╡ 5af67abe-ff2a-4e26-815f-1536ba7f6725
begin
	run_solver
	
	solve(solver, ic)
	@save "capture.jld2" capture
end

# ╔═╡ b2f39ca0-9fe5-41ea-888b-b2fec58d5726
begin
	if isfile("capture.jld2")
	    jldopen("capture.jld2", "r") do file
	        temp = file["capture"]  # local temporary variable
	        capture.t        = temp.t
	        capture.capacity = temp.capacity
	        capture.len      = temp.len
	        capture.c1       = temp.c1
	        capture.c2       = temp.c2
	        capture.c3       = temp.c3
	    end
	end
end

# ╔═╡ 8c49e690-167e-4c0d-a3cd-52af2f6adaa0
capture

# ╔═╡ cacad40a-3834-49fa-95db-d2143f330a9c
begin
	# Example: select the step
	show_step = 1
	
	# Determine color limits
	minval = 0
	maxval = maximum([maximum(ic[1]), maximum(ic[2])])
	
	# Create figure
	fig = Figure(resolution = (600, 600))
	ax = Axis(fig[1, 1], title="Heatmap with Colorbar", xlabel="X", ylabel="Y")
	
	# Plot heatmap
	hm = heatmap!(ax, capture.c1[show_step], colormap = :viridis, colorrange = (minval, maxval))
	
	cb = Colorbar(fig[1, 2], hm, label="Concentration")
	cb.ticks = [0, maxval]
	
	fig
end

# ╔═╡ 58e30cdc-6c0f-4566-b45d-973185ee685c
capture.c1[1]

# ╔═╡ Cell order:
# ╠═1b770759-4ef2-4e6c-915f-705e78b52c65
# ╠═338884f6-b349-4301-97a8-fb225bfb44e3
# ╠═b363f928-c52a-4555-99f4-5ff1e29a64d6
# ╠═1a55efd4-1d87-11f1-9ed7-8149f43b6dde
# ╠═0bca0ba2-40d6-47fd-ad9e-0fae2444a5a9
# ╠═d07779a3-2b88-47ca-a47b-ed97a29c4154
# ╠═82f06035-70aa-4eac-a40c-525f11e79f4c
# ╠═0541bc9d-128d-4b96-a45e-d53208c2842a
# ╠═232f1643-db37-4b93-b27c-4b1315ffa61a
# ╠═2acf9199-abe1-4fd9-8110-d8932dec009d
# ╠═6fed4699-655c-4361-ad72-c8355c928ece
# ╠═e51a9e75-cf96-4a9e-ab01-f8727d9bca2a
# ╠═43042319-c6a6-4425-b891-33010ab2d691
# ╠═5f2e679a-ebc4-4b3b-999c-69333611ba00
# ╠═6e2f7e0b-006d-498d-a325-f55cf4cbf3b1
# ╠═b1b9fe2a-d1aa-4709-b674-83654912d835
# ╠═16bca95f-5570-4cb1-8789-9f2f1023fe4d
# ╠═deb90105-cb3c-4868-bf52-3e8e7bc32c27
# ╠═5af67abe-ff2a-4e26-815f-1536ba7f6725
# ╠═b2f39ca0-9fe5-41ea-888b-b2fec58d5726
# ╠═8c49e690-167e-4c0d-a3cd-52af2f6adaa0
# ╠═cacad40a-3834-49fa-95db-d2143f330a9c
# ╠═58e30cdc-6c0f-4566-b45d-973185ee685c
