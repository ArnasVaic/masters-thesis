import datetime
from matplotlib import pyplot as plt
import numpy as np
from solvers.adi.config import Config

def pretty_time(seconds: float) -> str:
  return str(datetime.timedelta(seconds=int(seconds)))

def show_solution_frame(
    config: Config,
    t: np.ndarray,
    solution: np.ndarray,
    frame: int,
    element: int) -> None:
  extent = [
    0, config.dx * (config.resolution[0] - 1), 
    0, config.dy * (config.resolution[1] - 1)
  ]

  time = str(datetime.timedelta(seconds=int(t[frame])))

  plt.xlabel('x [μm]')
  plt.ylabel('y [μm]')
  plt.title(f'$c_{element + 1}$ at $t=$ {time}')

  plt.imshow(
    solution[frame, element, :, :], 
    aspect=1,
    extent=extent,
    vmin = solution[:, element].min(),
    vmax = solution[:, element].max()
  )

  plt.colorbar()

def show_solution_frames(
    t: np.ndarray,
    solution: np.ndarray,
    frames: list[int],
    element: int,
    filename: str | None = None,
    cmap: str = 'viridis',
    config: Config | None = None) -> None:
  
  extent = [
    0, config.dx * (config.resolution[0] - 1),
    0, config.dy * (config.resolution[1] - 1)
  ] if config is not None else [0,1,0,1]

  fig, axes = plt.subplots(1, 5, figsize=(15, 3), constrained_layout=True)  # 1 row, 5 columns

  fig.text(-0.03, 0.5, f'$c_{element + 1}$', va='center', rotation='horizontal', fontsize=24)

  for ax, frame in zip(axes, frames):

    time = str(datetime.timedelta(seconds=int(t[frame])))

    ax.set_title(f'$t=$ {time}', fontsize=18)
    im = ax.imshow(
      solution[frame, element, :, :],
      aspect=1,
      extent=extent,
      vmin = solution[:, element].min(),
      vmax = solution[:, element].max(),
      cmap=cmap
    )
    ax.axis('off')  # Remove axes for a cleaner look

  cbar = fig.colorbar(im, ax=axes.ravel().tolist(), shrink=0.8, orientation='vertical')
  cbar.set_label('Koncentracija', fontsize=12)

  if filename is not None:
    fig.savefig(filename, dpi=300, bbox_inches='tight')  # Save with high DPI
  plt.show()