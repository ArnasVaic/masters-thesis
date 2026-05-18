# %%
import yag_model as ym
import matplotlib.pyplot as plt

# %%
mp = ym.ModelParameters(
    [1e-2, 1e-2, 1e-2, 1e-2, 1e-2],
    [100.0, 50.0, 20.0]
)
ts = ym.FixedTimeStep(0.0001)
disc = ym.Discretization(1.0, 1.0, 40, 40)
br = ym.FixedStepBrake(10000)
cpt = ym.StrideCaptureTrigger(1)
cp = ym.QuantityCapture(10000, disc)
ic = ym.build_checkerboard_initial_condition(disc, 1.0, 1.0)
# %%
solver = ym.solve(disc, mp, ts, br, cpt, cp, ic)

plt.plot(cp.t_history, cp.q_history[0])

# for material in range(5):
#     plt.plot(cp.q_history[material])

# %%

