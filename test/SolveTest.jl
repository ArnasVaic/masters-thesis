using Test

using Revise
using BenchmarkTools

using Revise
using YagModel

stride = 1000
disc = Discretization(1.0, 1.0, 40, 40)
rp = ReactionParameters((15.0e-6, 15.0e-6, 15.0e-8), (-3.0, -5.0, 2.0), 146.0)
ic_cfg = Checkerboard(disc.grid, Size(20, 20), (5.0e-6, 3.0e-6))
ic = build_ic(ic_cfg)
ts = FixedStep(0.01)
q0 = sum(ic[1] + ic[2])
brake = RQTBrake(0.03, q0, stride)
capture = StrideCapture(stride)

io = open("solver_debug.log", "w")
logger = SimpleFileLogger(io)

solver = ADISolver(disc, rp, ts, brake, capture, logger)

# @btime 
solve(solver, ic)
