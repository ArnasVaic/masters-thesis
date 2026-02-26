import numpy as np
import numpy.typing as npt
import random
from solvers.adi.config import Config

def particle(c, i, w):
  arr = np.zeros((3, w, w))
  arr[i, :, :] = c
  return arr 

def random_ic(config: Config, m: int) -> npt.NDArray:
  """Generate an initial condition where cells are distributed in a random manner.

  Args:
      config (Config): Solver configuration
      m (int): Number of particles per side (in total there will be m**2 particles), has to divide config.resolution
  Returns:
      npt.NDArray: Randomized initial condition
  """
  
  assert config.resolution[0] % m == 0
  assert config.resolution[1] % m == 0
  
  particle_width = config.resolution[0] // m
  
  c0 = config.c0
  
  # split is always 50/50
  c1_particles = [ particle(3 * c0, 0, particle_width) for _ in range(m * m // 2) ]
  c2_particles = [ particle(5 * c0, 1, particle_width) for _ in range(m * m // 2) ]
  
  c1_particles.extend(c2_particles)
  particles = c1_particles
  
  random.shuffle(particles)
  
  lines = [ ]
  for i in range(m):
    line = particles[i * m]
    for j in range(m - 1):
      # lines get concatenated along x axis?
      line = np.concatenate((line, particles[i * m + j + 1]), axis=1)
    lines.append(line)
  
  ic = lines[0]
  for i in range(m - 1):
    ic = np.concatenate((ic, lines[i + 1]), axis=2)
  
  return ic