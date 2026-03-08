using Test

using Revise
using BenchmarkTools

include("../src/YagModel.jl")
using .YagModel

disc = Discretization(1.0, 1.0, 40, 40)
rp = ReactionParameters((15.0e-6, 15.0e-6, 15.0e-8), (-3.0, -5.0, 2.0), 146.0)
ic_cfg = Checkerboard(disc.grid, Size(20, 20), (5.0e-6, 3.0e-6))
ic = build_ic(ic_cfg)
ts = FixedStep(0.01)
q0 = sum(ic[1] + ic[2])
brake = RQTBrake(0.03, q0, 1)

@btime solve(
    $disc,
    $rp,
    $ic,
    $ts,
    $brake
)
