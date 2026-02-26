from dataclasses import dataclass
from logging import Logger
import logging
import datetime
import sys
from typing import Callable
import numpy as np
import scipy.linalg as la
from ics.checkerboard import checkerboard_ic
from solvers.mixer import SubdivisionMixer
from solvers.adi.config import Config
from solvers.adi.state import State
from solvers.adi.time_step_strategy import SCGQMStep

NUM_OF_ELEMENTS = 3

@dataclass
class Solver:
  """ADI Solver for the YAG reaction-diffusion system"""
  config: Config

  half: np.ndarray # Container for the half-step solution

  # time step for which the banded matrices (and mu) are initialized
  # if this value changes, the banded matrices and mu will be
  # initialized once more and this value updated.
  initialized_dt: float

  # Matrices for finding half-step solution
  ax_banded: np.ndarray

  # Matrices for finding next-step solution
  ay_banded: np.ndarray

  # Aggregated coefficients (each of these has 3 coefficients)
  mu_x: list[float]
  mu_y: list[float]
  mu_m: list[float]

  logger: Logger | None = None

  def __init__(self, config: Config, logger: Logger | None = None):
    self.config = config
    self.stopper = config.stopper
    
    nx, ny = self.config.resolution

    self.half = np.zeros((NUM_OF_ELEMENTS, nx, ny))
    self.ax_banded = np.zeros((3, 3, nx))
    self.ay_banded = np.zeros((3, 3, nx))

    self.mu_x = [0, 0, 0]
    self.mu_y = [0, 0, 0]
    self.mu_m = [0, 0, 0]
    self.logger = logger or logging.getLogger("__name__")

    self.initialize_banded(config.time_step_strategy.dt)

  def solve_line(self, y: int, m: int, ny: int, mu_y: float, mu_m: float, h: np.ndarray, c: np.ndarray) -> None:
    yt, yb = min(y + 1, ny - 1), max(y - 1, 0)
    h[m, :, y] = la.solve_banded((1, 1), self.ax_banded[m],
      (1 - 2 * mu_y) * c[m, :, y]
      + mu_y * (c[m, :, yb] + c[m, :, yt])
      + mu_m * c[0, :, y] * c[1, :, y]
    )

  def solve_column(self, x: int, m: int, nx: int, mu_x: float, mu_m: float, h: np.ndarray, c: np.ndarray) -> None:
    xl, xr = max(x - 1, 0), min(x + 1, nx - 1)
    c[m, x, :] = la.solve_banded((1, 1), self.ay_banded[m],
      mu_m * h[0, x, :] * h[1, x, :]
      + (1 - 2 * mu_x) * h[m, x, :]
      + mu_x * (h[m, xl, :] + h[m, xr, :])
    )

  def update_half(self, state: State, element_index: int) -> None:
    m = element_index
    _, ny = self.config.resolution
    mu_y, mu_m = self.mu_y[m], self.mu_m[m]
    c, h = state.current, self.half
    for y in range(ny):
      self.solve_line(y, m, ny, mu_y, mu_m, h, c)

  def update_next(self, state: State, element_index: int) -> None:
    m = element_index
    nx, _ = self.config.resolution
    mu_x, mu_m = self.mu_x[m], self.mu_m[m]
    c, h = state.current, self.half

    for x in range(nx):
      self.solve_column(x, m, nx, mu_x, mu_m, h, c)

  def solve_step(self, state: State) -> None:
    """Solve for the next step, directly modifies the state
    """
    # update the time step
    
    dt = self.config.time_step_strategy.dt

    self.update_half(state, 0)
    self.update_half(state, 1)
    self.update_half(state, 2)

    self.update_next(state, 0)
    self.update_next(state, 1)
    self.update_next(state, 2)

    state.time_step = state.time_step + 1
    state.time = state.time + dt

    # TODO: this is expensive, maybe think of a way to not call sum each frame
    state.current_quantity = frame_quantity(state.current)
    self.config.time_step_strategy.update_dt(state, self.config.mixer.mix_times)

  def solve(self, c0: np.ndarray, capture: Callable) -> tuple[np.ndarray, np.ndarray]:
    state = State(c0)
    captured_times, captured_result = [0], [capture(c0)]

    self.log_initial_info()

    while True:
      
      self.check_and_recalculate_matrices()
      self.solve_step(state)
      self.mix(state, capture, captured_result, captured_times)
      
      self.log_periodic_info(state)

      if state.time_step % self.config.frame_stride == 0:
        captured_result.append(capture(state.current))
        captured_times.append(state.time)

      # maybe stopper doesn't need to run every frame?
      if self.stopper.should_stop(state):
        # capture the moment when reaction stops
        captured_result.append(capture(state.current))
        captured_times.append(state.time)
        break
    return np.array(captured_times), np.array(captured_result)

  def mix(self, state: State, capture: Callable, captured_result: np.ndarray, captured_times: np.ndarray) -> None:
    mixer = self.config.mixer
    dt = self.config.time_step_strategy.dt
    if not mixer.should_mix(state, dt, isinstance(self.config.time_step_strategy, SCGQMStep)):
      return

    self.logger.info(f'mixing, step = {state.time_step} (index in result: {len(captured_result)}), time = {state.time}')
    state.current = mixer.mix(state.current)
    state.mixing_steps.append(state.time_step)
    # capture state just after mixing
    captured_result.append(capture(state.current))
    captured_times.append(state.time)

    # reset time step
    self.config.time_step_strategy.aftermix_reset()

  def initialize_banded(self, dt: float) -> None:
    dx, dy = self.config.dx, self.config.dy

    half_dtk = dt * self.config.k / 2
    dt_over_dx2 = dt / (2 * dx ** 2)
    dt_over_dy2 = dt / (2 * dy ** 2)

    self.mu_m[:] = self.config.alpha * half_dtk
    self.mu_x[:] = self.config.D * dt_over_dx2
    self.mu_y[:] = self.config.D * dt_over_dy2

    initialize_banded(self.ax_banded, self.mu_x[0], 0)
    initialize_banded(self.ax_banded, self.mu_x[1], 1)
    initialize_banded(self.ax_banded, self.mu_x[2], 2)

    initialize_banded(self.ay_banded, self.mu_y[0], 0)
    initialize_banded(self.ay_banded, self.mu_y[1], 1)
    initialize_banded(self.ay_banded, self.mu_y[2], 2)

    self.initialized_dt = dt

  def check_and_recalculate_matrices(self):
     # check if banded matrices should be reinitialized
    current_dt: float = self.config.time_step_strategy.dt
    if abs(self.initialized_dt - current_dt) > sys.float_info.epsilon:
      diff: float = self.initialized_dt - current_dt
      self.logger.info(f"Recalculating banded, old dt = {self.initialized_dt:.02f}, new dt = {current_dt:.02f}, difference = {diff:.2e}")
      self.initialize_banded(current_dt)
  
  def validation(self, state: State) -> None:
    # TODO: this works only for constant size dt
    if state.time_step == 1:
      # this should probably be called each frame when an adaptive time stepper is used
      validate_frame_stable(self.config, state.current)
        
  def log_initial_info(self) -> None:
    dt = self.config.time_step_strategy.dt
    dx, dy = self.config.dx, self.config.dy
    D, k = self.config.D, self.config.k
    size = self.config.size
    resolution = self.config.resolution
    self.logger.info(f'starting simulation, dt={dt}, dx={dx}, dy={dy}, D={D},k={k}, size={size}, resolution={resolution}')

  def log_periodic_info(self, state: State) -> None:
    # every frame_stride frames log the remaining quantity ratio
    step = state.time_step
    if step % self.config.frame_stride == 0:
      dt = self.config.time_step_strategy.dt
      q, q0 = state.current_quantity, state.initial_quantity
      r = 100 * (q[0] + q[1]) / (q0[0] + q0[1])
      r1, r2 = 100 * q[0]/q0[0], 100 * q[1]/q0[1]
      time = str(datetime.timedelta(seconds=int(state.time)))
      self.logger.info(f't: {time}, step: {step}, dt: {dt} r: {r:.02f}, r1: {r1:.02f}, r2 {r2:.02f}')

def initialize_banded(array: np.ndarray, mu: float, element_index: int) -> None:
  i = element_index # alias for brevity
  # initialize first and last element of sup & sub-diagonals as zeros
  # this is required format by scipy
  array[i, 0, 0] = array[i, 2, -1] = 0

  # initialize sup & sub-diagonals
  array[i, 0, 1:] = array[i, 2, :-1] = - mu

  # initialize the main diagonal
  array[i, 1, 0] = array[i, 1, -1] = 1 + mu
  array[i, 1, 1:-1] = 1 + 2 * mu

def build_banded_matrix_A(n: int, mu: float) -> np.ndarray:
  sub_diag = np.repeat(-mu, n)
  sub_diag[0] = 0

  sup_diag = np.repeat(-mu, n)
  sup_diag[-1] = 0

  diag = np.repeat(1 + 2 * mu, n)
  diag[0] = diag[-1] = 1 + mu

  return np.array([sub_diag, diag, sup_diag])

def frame_quantity(frame: np.ndarray) -> np.ndarray:
  # single frame of solution should be of shape [3, w, h]
  return frame.sum(axis=(1,2))

def validate_solution_stable(config: Config, solution: np.ndarray):
  # this check is very specific to the initial conditions
  # take a line at about a quarter of the total height from
  # the bottom (specific height doesn't really matter since
  # the initial conditions are very symmetric)
  y = int(config.resolution[1] / 4)
  df = np.diff(solution[1, 0, :, y])
  assert np.sum((df[:-1] > 0) & (df[1:] < 0)) < 1, "Simulation not stable"

def validate_frame_stable(config: Config, frame: np.ndarray):
  # this check is very specific to the initial conditions
  # take a line at about a quarter of the total height from
  # the bottom (specific height doesn't really matter since
  # the initial conditions are very symmetric)
  y = int(config.resolution[1] / 4)
  df = np.diff(frame[0, :, y])
  assert np.sum((df[:-1] > 0) & (df[1:] < 0)) < 1, "Simulation not stable"
  
def reaction_end_time(config: Config, t: float) -> float:
  assert config.mixer is SubdivisionMixer
  config.mixer.mix_times = [ t ]
  solver = Solver(config)
  c0 = checkerboard_ic(config)
  ts, _ = solver.solve(c0)
  
  # assert config.time_step_strategy is ConstantTimeStep
  t_end = ts[-1] * config.time_step_strategy.dt
  return t_end

def get_quantity_over_time(config: Config, solution: np.ndarray) -> np.ndarray:
  # shape of the solution is assumed to be [T, 3, W, H]
  total_points = config.resolution[0] * config.resolution[1]
  # shape of the result is [T, 3]
  return solution.sum(axis=(2, 3)) / total_points