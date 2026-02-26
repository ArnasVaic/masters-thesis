# %%

import logging

import numpy as np
from tqdm import tqdm
from solvers.utils.plotting import show_solution_frame, show_solution_frames
from ics.random import random_ic
from solvers.adi.config import large_config
from solvers.adi.solver import Solver
import random

logging.basicConfig(
  filename='debug.log',
  filemode='w',
  format='%(asctime)s,%(msecs)03d %(name)s %(levelname)s %(message)s',
  datefmt='%Y-%m-%d %H:%M:%S',
  level=logging.INFO)

ord = 3
config = large_config(order=ord, temperature=1600)
config.frame_stride = 10000000 # way too big
  
ts_end = []
for i in tqdm(range(10)):
  c0 = random_ic(config, 2**ord)
  t, c = Solver(config).solve(c0, lambda f: f.copy())
  ts_end.append(t)

# %%



# %%

import matplotlib.pyplot as plt


img = c0 * 51000000
plt.imshow(img.transpose((1, 2, 0)))

# %%

show_solution_frames(t, c, [0,1,2,3], 2)
