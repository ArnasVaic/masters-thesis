from dataclasses import dataclass
import numpy as np

def frame_quantity(frame: np.ndarray) -> np.ndarray:
  # single frame of solution should be of shape [3, w, h]
  return frame.sum(axis=(1,2))

@dataclass
class State:
  """State of the solver"""

  # Initial state of the simulation with shape [ 3, width, height ]
  initial: np.ndarray

  # Current state of the simulation with shape [ 3, width, height ]
  current: np.ndarray

  # Previous state of the simulation with shape [ 3, width, height ]
  previous: np.ndarray

  # initial quantity of each element (shape [3])
  initial_quantity: np.ndarray

  # current quantity of each element (shape [3])
  current_quantity: np.ndarray

  # Time steps immediately after which mixing took place
  mixing_steps: list[int]

  # current simulation time
  time: float = 0.0

  # simulation time step
  time_step: int = 0

  def __init__(self, initial: np.ndarray):
    self.initial = np.copy(initial)
    self.current = np.copy(initial)
    self.previous = np.copy(initial)
    self.initial_quantity = frame_quantity(initial)
    self.current_quantity = frame_quantity(initial)
    self.mixing_steps = []
