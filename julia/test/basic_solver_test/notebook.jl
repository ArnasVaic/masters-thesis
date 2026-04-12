### A Pluto.jl notebook ###
# v0.20.24

using Markdown
using InteractiveUtils

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

# ╔═╡ 569ebdf4-bb04-4991-ae98-8c7590e897eb
using Debugger

# ╔═╡ 7bd3c3fe-4f8e-4392-9411-4fef9d0ad732
begin
	using Printf
	
	function hours_to_hhmm(hours::Float64)
	    h = floor(Int, hours)
	    m = round(Int, (hours - h) * 60)
	    
	    if m == 60
	        h += 1
	        m = 0
	    end
	    
	    @sprintf("%02dh %02dmin", h, m)
	end
end

# ╔═╡ 0541bc9d-128d-4b96-a45e-d53208c2842a
stride = 1000 # match capture and brake stride to capture final frame

# ╔═╡ 232f1643-db37-4b93-b27c-4b1315ffa61a
disc = Discretization(2, 20) # particles, particle resolution

# ╔═╡ 2acf9199-abe1-4fd9-8110-d8932dec009d
rp = ReactionParameters(Val(1600))

# ╔═╡ 6fed4699-655c-4361-ad72-c8355c928ece
ic = build_checkerboard_ic(disc, 5.0e-6, 3.0e-6)

# ╔═╡ fc31bcf5-85ad-4ded-946d-9cd981e6c4e1
q0 = reagent_quantity(ic, disc)

# ╔═╡ 17f8df56-ac54-4ed8-be61-2f7c59ce788f
initial_dt = 0.001

# ╔═╡ e51a9e75-cf96-4a9e-ab01-f8727d9bca2a
brake = RQTBrake(0.03, q0, stride)

# ╔═╡ 43042319-c6a6-4425-b891-33010ab2d691
ts = SCGQMStep(initial_dt, 2.0, 400, 10.0, initial_dt, q0, 1.01 * brake.threshold, disc)

# ╔═╡ 5f2e679a-ebc4-4b3b-999c-69333611ba00
capture = StrideCapture(stride, 1000, disc)

# ╔═╡ 6e2f7e0b-006d-498d-a325-f55cf4cbf3b1
io = open("debug.log", "w")

# ╔═╡ b1b9fe2a-d1aa-4709-b674-83654912d835
logger = SimpleFileLogger(io)

# ╔═╡ 16bca95f-5570-4cb1-8789-9f2f1023fe4d
solver = ADISolver(disc, rp, ts, brake, capture, logger)

# ╔═╡ 5af67abe-ff2a-4e26-815f-1536ba7f6725
@enter solve(solver, ic)

# ╔═╡ 324f9190-43ce-4c1e-b903-54a0df7c1791
@save "capture.jld2" capture

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
	show_step = 700

	minval, maxval = 0, maximum([maximum(ic[1]), maximum(ic[2])])
	fig = Figure(fontsize=18)

	time = hours_to_hhmm(capture.t[show_step] / 3600)
	
	ax = Axis(
		fig[1, 1], 
		title=L"Concentration of $c_3$ at step %$(show_step) (%$(time))", 
		xlabel="X", 
		ylabel="Y"
	)

	ct = capture.c3[show_step]
	
	hm = heatmap!(
		ax,
		ct, 
		colormap = :viridis, 
		colorrange = (minval, maxval)
	)
	
	Colorbar(fig[:, end+1], hm, label="Concentration")

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
# ╠═fc31bcf5-85ad-4ded-946d-9cd981e6c4e1
# ╠═17f8df56-ac54-4ed8-be61-2f7c59ce788f
# ╠═e51a9e75-cf96-4a9e-ab01-f8727d9bca2a
# ╠═43042319-c6a6-4425-b891-33010ab2d691
# ╠═5f2e679a-ebc4-4b3b-999c-69333611ba00
# ╠═6e2f7e0b-006d-498d-a325-f55cf4cbf3b1
# ╠═b1b9fe2a-d1aa-4709-b674-83654912d835
# ╠═16bca95f-5570-4cb1-8789-9f2f1023fe4d
# ╠═569ebdf4-bb04-4991-ae98-8c7590e897eb
# ╠═5af67abe-ff2a-4e26-815f-1536ba7f6725
# ╠═324f9190-43ce-4c1e-b903-54a0df7c1791
# ╠═b2f39ca0-9fe5-41ea-888b-b2fec58d5726
# ╠═8c49e690-167e-4c0d-a3cd-52af2f6adaa0
# ╠═7bd3c3fe-4f8e-4392-9411-4fef9d0ad732
# ╠═cacad40a-3834-49fa-95db-d2143f330a9c
# ╠═58e30cdc-6c0f-4566-b45d-973185ee685c
