# %%

import numpy as np
import yag_model as ym
import yag_utils.stoichiometry
from yag_utils.initial_conditions import checkerboard

import matplotlib.pyplot as plt
import matplotlib as mpl

# %%
disc = ym.discretization(mesh_resolution=(40, 40), physical_size=(1.0, 1.0))
ic = checkerboard(disc, 50.0, 30.0)

config = ym.solver_config(
    discretization=disc,
    step=ym.fixed_step(dt=0.0001),
    brake=ym.fixed_step_brake(last_step=100000),
    capture=ym.capture_config(
        trigger=ym.stride_trigger(every=100),
        sink=ym.in_memory_sink(capacity=1000),
    ),
    # 5 Al2O3 + 3 Y2O3 -> 2 YAG
    stoichiometry=yag_utils.stoichiometry.simplified,
)

mp = ym.model_params(
    D=[1e-2, 1e-2, 1e-2, 1e-2, 1e-2], 
    k=[10.0, 5.0, 1.0]
)

# %%
c, t = ym.solve(config, ic, mp).all()
# %%
# Return indicator of "symmetry" along
# the vertical axis. The maximum difference 
# between mesh cell values at the same x
# but mirror y (along mid point) values
frame = 900

# Mirror along both spatial axes
cf = c[:, :, ::-1, ::-1]
cdiff = cf - c

fig, axes = plt.subplots(1, 5, figsize=(20, 4))

for material in range(5):
    f = cdiff[frame, material]

    im = axes[material].imshow(f)
    axes[material].set_title(f"Material {material + 1}")
    axes[material].set_axis_off()

    fig.colorbar(im, ax=axes[material], shrink=0.8)

plt.tight_layout()
plt.show()

print("float64 precision ~15–16 decimal places")
print("local max diff:", np.max(cdiff[frame]))
print("global max diff:", np.max(cdiff))
# %%

# plt.imshow(c[frame, 4])    