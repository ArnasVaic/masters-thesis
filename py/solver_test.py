# %%
import numpy as np
import yag_model as ym
import matplotlib.pyplot as plt
from yag_utils.channels import LABELS
from yag_utils.debug import config_info
from yag_utils.mass import field_masses, total_mass
from yag_utils.optimization import DEFAULT_SCALES, optimization_config
from yag_utils.scaling import to_dimensionless

# %% Solver config

scales = DEFAULT_SCALES
logD = [
    -15.520843103369195,
    -14.962864487926721,
    -14.08355774833853,
    -15.939166775886509,
    -15.064413562884312
]

logK = [
    -8.81287507930491,
    -8.171172197361324,
    -8.998608159571566
]

mp = ym.model_params(
    # [ 1e-15 ] * 5,
    # [ 1e-8 ] * 3
    D=[10**d for d in logD],
    k=[10**k for k in logK]
)
mp_nd = to_dimensionless(mp, scales)

# Experiment setup, but capture concentration fields every 100 steps
config, ic = optimization_config(
    scales,
    capture=ym.capture_config(
        trigger=ym.stride_trigger(every=100),
        sink=ym.in_memory_sink(capacity=300),
    ),
)

# config.step = ym.fixed_step(dt=0.00001)
# config.brake = ym.fixed_time_brake(final_time=1.0)

disc = config.discretization
config_info(config, ic, mp_nd, scales)

# %% Solve
result = ym.solve(config, ic, mp_nd)
c, t = result.all()

# %%

m0 = total_mass(ic, disc)
m = field_masses(c, disc)

for i in range(5):
    plt.plot(t, 100 * m[:, i] / m0, label=LABELS[i])

plt.plot(t, 100 * m.sum(axis=1) / m0, label='$\\Sigma$')
plt.xlabel('Reakcijos laikas (s)')
plt.ylabel('Medžiagų masės dalys (%)')
plt.legend()
plt.tight_layout()

# %%

frame = 1
assert frame < len(result)
species = 1
plt.title(f"$c_{1+species}(t={t[frame]})$")

print(f"min = {np.min(c)}, max = {np.max(c)}")
mx = np.max(c)

plt.imshow(c[frame, species], vmin=0.0, vmax=mx)
#plt.imshow(c[frame, species])

plt.colorbar()
# %%
