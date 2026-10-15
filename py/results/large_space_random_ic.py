# %%

import yag_model as ym
import yag_utils.initial_conditions as ics
import matplotlib.pyplot as plt
# %%

disc = ym.discretization(mesh_resolution=(160, 160), physical_size=(1.0, 1.0))
ic = ics.perlin_based(
    disc, 
    c1=5.0, c2=3.0, n=8, t=0.25)

config = ym.solver_config(
    discretization=disc,
    step=ym.fixed_step(dt=1e-3),
    brake=ym.fixed_step_brake(last_step=int(1e5)),
    capture=ym.capture_config(
        trigger=ym.stride_trigger(every=int(1e4)),
        sink=ym.in_memory_sink(capacity=int(1e4)),
    ),
)

mp = ym.model_params(
    D=[1e-2, 1e-2, 1e-2, 1e-2, 1e-2], 
    k=[10.0, 5.0, 1.0]
)

# %%
c, t = ym.solve(config, ic, mp).all()

# %%

frame = 0
plt.imshow(ic[frame])