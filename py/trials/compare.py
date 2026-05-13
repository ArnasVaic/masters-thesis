# %%

import re

import numpy as np
from ics.checkerboard import checkerboard_ic
from solvers.utils.plotting import show_solution_frame
from solvers.adi.config import Config
from solvers.adi.time_step_strategy import ConstantTimeStep
from solvers.mixer import SubdivisionMixer
from solvers.stopper import TotalStepsStopper
from solvers.adi.solver import Solver
import matplotlib.pyplot as plt


# %%

config = Config(
    _order = (0, 0),
    size = (1.0, 1.0),
    resolution = (40, 40),
    D = np.array([0.01, 0.01, 0.01]),
    k = 0.0,
    c0 = 5.0,
    stopper = TotalStepsStopper(10000),
    frame_stride = 1,
    mixer = SubdivisionMixer(np.array([]), (2, 2), 'perfect'),
    time_step_strategy = ConstantTimeStep(0.0001),
    alpha = np.array([-3, -5, 2])
  )

solver = Solver(config)

ic = checkerboard_ic(config)

# %%
t, c = solver.solve(ic, lambda f: f.copy())

# %%

show_solution_frame(config, t, c, 4340, 0)

# %%

data = []
with open("trials/data.txt") as f:
    for line in f:
        nums = re.findall(r"[-+]?\d*\.\d+|\d+", line)
        data.append(float(nums[-1]))  # take the VALUE, not index

arr = np.array(data).reshape(40, 40)

print(arr)
    
# %%
plt.imshow(arr)
plt.colorbar()
