# Figures explaining the Perlin noise based initial condition:
#   perlin-construction.png  - gradients on the lattice -> noise field -> thresholded initial condition
#   perlin-parameter-grid.png - how the lattice size n and the c1 fraction t shape the initial condition

# %%
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import ListedColormap
from yag_utils.initial_conditions import perlin_noise
from yag_utils.paths import diagrams_dir

RESOLUTION = 256
SEED = 3

# Same look as the other thesis figures
plt.style.use("ggplot")
plt.rcParams.update({
    "font.family": "Libertinus Serif",
    "mathtext.fontset": "custom",
    "mathtext.it": "Libertinus Serif:italic",
    "mathtext.rm": "Libertinus Serif",
    "mathtext.cal": "Libertinus Serif",
    "font.size": 11,
    "axes.labelsize": 12,
    "axes.titlesize": 11,
})

# c1 is left blank and c2 is light gray, like the particle initial conditions drawn in the thesis
IC_CMAP = ListedColormap(["#dedede", "#ffffff"])


def noise_and_gradients(n: int, m: int, seed: int) -> tuple[np.ndarray, np.ndarray]:
    """Noise field and the lattice gradient angles it was built from.

    perlin_noise draws the angles first, so the same seed reproduces them.
    """
    noise = perlin_noise(RESOLUTION, RESOLUTION, n, m, np.random.default_rng(seed))
    angles = np.random.default_rng(seed).uniform(0, 2 * np.pi, size=(m + 1, n + 1))
    return noise, angles


def threshold(noise: np.ndarray, t: float) -> np.ndarray:
    """True where c1 is placed, the same rule as perlin_based_rectangles."""
    return noise >= np.quantile(noise, 1 - t)


def domain_axes(ax, n: int, m: int, pad: float = 0.0):
    ax.set_xlim(-pad, n + pad)
    ax.set_ylim(-pad, m + pad)
    ax.set_aspect("equal")
    ax.set_xticks([])
    ax.set_yticks([])
    ax.grid(False)
    ax.set_facecolor("none")
    for spine in ax.spines.values():
        spine.set_visible(False)


def pixel_centers(size: float) -> np.ndarray:
    return (np.arange(RESOLUTION) + 0.5) * size / RESOLUTION


def draw_boundary(ax, noise: np.ndarray, level: float, n: int, m: int, linewidth: float):
    """c1/c2 interface as a contour of the noise, so it is smooth instead of following pixel edges."""
    ax.contour(
        pixel_centers(n), pixel_centers(m), noise,
        levels=[level], colors="black", linewidths=linewidth, linestyles="solid",
    )


def draw_frame(ax, n: int, m: int):
    ax.plot([0, n, n, 0, 0], [0, 0, m, m, 0], color="black", linewidth=1.0)


def draw_lattice(ax, n: int, m: int, color: str):
    for i in range(n + 1):
        ax.plot([i, i], [0, m], color=color, linewidth=0.6, linestyle="--")
    for j in range(m + 1):
        ax.plot([0, n], [j, j], color=color, linewidth=0.6, linestyle="--")


def draw_gradients(ax, angles: np.ndarray, color: str):
    m1, n1 = angles.shape
    xx, yy = np.meshgrid(np.arange(n1), np.arange(m1))
    ax.scatter(xx, yy, s=10, color=color, zorder=3)
    ax.quiver(
        xx, yy, np.cos(angles), np.sin(angles),
        angles="xy", scale_units="xy", scale=1 / 0.42,
        color=color, width=0.012, headwidth=4, headlength=4.5, headaxislength=4, zorder=4,
    )


# %%
# Construction: lattice gradients -> smooth noise -> thresholded initial condition
N, T = 4, 0.5
noise, angles = noise_and_gradients(N, N, SEED)
mask = threshold(noise, T)
extent = (0, N, 0, N)
pad = 0.5
limit = np.abs(noise).max()

fig, (ax_grad, ax_noise, ax_ic) = plt.subplots(1, 3, figsize=(7.2, 2.9), dpi=150, layout="constrained")

domain_axes(ax_grad, N, N, pad)
draw_lattice(ax_grad, N, N, "0.6")
draw_gradients(ax_grad, angles, "0.15")
ax_grad.set_title("(a) Atsitiktiniai gradientai")

domain_axes(ax_noise, N, N, pad)
image = ax_noise.imshow(noise, extent=extent, origin="lower", cmap="RdBu_r", vmin=-limit, vmax=limit)
draw_lattice(ax_noise, N, N, "white")
draw_gradients(ax_noise, angles, "0.15")
draw_boundary(ax_noise, noise, np.quantile(noise, 1 - T), N, N, linewidth=1.2)
ax_noise.set_title("(b) Perlino triukšmas")
colorbar = fig.colorbar(image, ax=ax_noise, location="bottom", shrink=0.8, aspect=25, pad=0.02)
colorbar.outline.set_visible(False)
colorbar.ax.tick_params(labelsize=9)

domain_axes(ax_ic, N, N, pad)
ax_ic.imshow(mask, extent=extent, origin="lower", cmap=IC_CMAP, vmin=0, vmax=1, interpolation="nearest")
draw_boundary(ax_ic, noise, np.quantile(noise, 1 - T), N, N, linewidth=0.6)
draw_frame(ax_ic, N, N)
ax_ic.set_title(f"(c) Pradinė sąlyga, $t = {T}$")

fig.savefig(diagrams_dir() / "perlin-construction.png", dpi=300, bbox_inches="tight", pad_inches=0.05)
plt.show()

# %%
# Parameter grid: one noise field per row, thresholded at a different c1 fraction per column
SIZES = [2, 4, 8]
FRACTIONS = [0.25, 0.5, 0.75]

fig, axes = plt.subplots(
    len(SIZES), len(FRACTIONS), figsize=(5.4, 5.6), dpi=150, layout="constrained"
)

for row, n in enumerate(SIZES):
    noise, _ = noise_and_gradients(n, n, SEED)
    for col, t in enumerate(FRACTIONS):
        ax = axes[row, col]
        mask = threshold(noise, t)
        domain_axes(ax, n, n, pad=0.0)
        ax.imshow(mask, extent=(0, n, 0, n), origin="lower", cmap=IC_CMAP, vmin=0, vmax=1, interpolation="nearest")
        draw_boundary(ax, noise, np.quantile(noise, 1 - t), n, n, linewidth=0.6)
        draw_frame(ax, n, n)

        if row == 0:
            ax.set_title(f"$t = {t}$")
        if col == 0:
            ax.set_ylabel(f"$n = {n}$", rotation=0, labelpad=18, va="center", color="black")

fig.savefig(diagrams_dir() / "perlin-parameter-grid.png", dpi=300, bbox_inches="tight", pad_inches=0.05)
plt.show()
