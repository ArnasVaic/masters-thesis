using YagModel
using JLD2

# match capture and brake stride to capture final frame
stride = 10000
disc = Discretization(2, 20) # particles, particle resolution
rp = ReactionParameters(Val(1600))
ic = build_checkerboard_ic(disc, 5.0e-6, 3.0e-6)
q0 = reagent_quantity(ic, disc)
initial_dt = 0.01
brake = RQTBrake(0.03, q0, stride)
ts = SCGQMStep(initial_dt, 2.0 , 400, 10.0, initial_dt, q0, 1.01 * brake.threshold, disc)
# ts = FixedStep(initial_dt)
# capture = StrideCapture(stride, 10000, disc)
capture = NoCapture()
io = open("debug.log", "w")
logger = SimpleFileLogger(io)
solver = ADISolver(disc, rp, ts, brake, capture, logger)

solve(solver, ic)

@save "capture-scgqm.jld2" capture