# %%
# Peaks of the n = 4 end time distribution, split by the mean particle distance
#
# Uses the trials of random_squares_end_time.py. For every particle the distance from its centre
# to the nearest centre of a particle of the other material is taken, in particle widths, and
# averaged over all particles. The n = 4 density is split into the most common averages, each
# part scaled by its share of the trials so the parts add up to the full curve.

from collections import Counter

import matplotlib.pyplot as plt
import numpy as np
from scipy import ndimage
from scipy.stats import gaussian_kde
from yag_utils.batch import load_rows
from yag_utils.paths import diagrams_dir, repo_root

SIZE = 4
GROUPS = 5
RESULTS_PATH = (
    repo_root() / "py" / "results" / "reaction_end_time_based_on_size" / "data" / "random_squares_end_time_k1.csv"
)
SYMBOLS = {1.0: "1", 2**0.5: "√2", 2.0: "2", 5**0.5: "√5", 8**0.5: "2√2", 3.0: "3"}


def arrangement(trial: int) -> np.ndarray:
    """Particles of the trial as in random_rectangles: True is c1, row 0 is the bottom row."""
    blocks = np.random.default_rng([SIZE, trial]).choice(SIZE * SIZE, size=SIZE * SIZE // 2, replace=False)
    g = np.zeros((SIZE, SIZE), dtype=bool)
    g[blocks // SIZE, blocks % SIZE] = True
    return g


def distances(g: np.ndarray) -> np.ndarray:
    """Per particle, distance between centres to the nearest particle of the other material."""
    return np.where(g, ndimage.distance_transform_edt(g), ndimage.distance_transform_edt(~g))


def composition(d: np.ndarray) -> str:
    """Particles farther than 1, e.g. "1×√2, 1×2"."""
    far = Counter(min(SYMBOLS, key=lambda s: abs(s - v)) for v in d.ravel() if v > 1.001)
    return ", ".join(f"{k}×{SYMBOLS[s]}" for s, k in sorted(far.items())) or "visos 1"


# %%
trials, T = [], []
for r in load_rows(RESULTS_PATH):
    if int(r["size"]) == SIZE:
        trials.append(int(r["trial"]))
        T.append(float(r["end_time"]))
T = np.array(T)
grids = [arrangement(t) for t in trials]
dists = [distances(g) for g in grids]
means = np.array([round(d.mean(), 4) for d in dists])
comps = np.array([composition(d) for d in dists])
top = sorted(m for m, _ in Counter(means).most_common(GROUPS))

# One Gaussian bandwidth for all parts (that of the full curve), so the parts add up to it
h = np.sqrt(gaussian_kde(T).covariance[0, 0])
xs = np.linspace(0, 320, 800)


def part(t: np.ndarray) -> np.ndarray:
    return np.exp(-0.5 * ((xs[:, None] - t[None, :]) / h) ** 2).sum(axis=1) / (len(T) * h * np.sqrt(2 * np.pi))


total = part(T)
peaks = [xs[i] for i in range(1, len(xs) - 1) if total[i] > total[i - 1] and total[i] >= total[i + 1]]

# %%
# Example arrangement of each group, the trial closest to the group median, as strings for the
# random-ic style figures of doc/chapters/larger-spaces.typ: one string per row from the bottom,
# 0 is a c1 particle and 1 a c2 particle. Each mark is a particle farther than 1 with one of its
# nearest particles of the other material: (i, j, nearest i, nearest j, distance)
for m in top:
    idx = np.flatnonzero(means == m)
    k = idx[np.argmin(np.abs(T[idx] - np.median(T[idx])))]
    g, d = grids[k], dists[k]
    rows = " ".join("".join("0" if v else "1" for v in row) for row in g)
    marks = []
    for j, i in zip(*np.nonzero(d > 1.001)):
        others = [(jj, ii) for jj in range(SIZE) for ii in range(SIZE) if g[jj, ii] != g[j, i]]
        jj, ii = min(others, key=lambda o: (o[0] - j) ** 2 + (o[1] - i) ** 2)
        marks.append((int(i), int(j), ii, jj, SYMBOLS[min(SYMBOLS, key=lambda s: abs(s - d[j, i]))]))
    print(f"mean {m:.3f} ({comps[k]}), trial {trials[k]}, end time {T[k]:.1f} s: \"{rows}\" marks {marks}")

# %%
plt.style.use("ggplot")
plt.rcParams.update({
    "font.family": "Libertinus Serif",
    "mathtext.fontset": "custom",
    "mathtext.it": "Libertinus Serif:italic",
    "mathtext.rm": "Libertinus Serif",
    "mathtext.cal": "Libertinus Serif",
    "font.size": 11,
    "axes.labelsize": 12,
    "axes.spines.top": False,
    "axes.spines.right": False,
    "grid.alpha": 0.3,
})

COLORS = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#6250d6"]

fig, ax = plt.subplots(figsize=(6.6, 3.8), dpi=150, layout="constrained")
for color, m in zip(COLORS, top):
    sel = means == m
    ax.plot(xs, part(T[sel]), color=color, linewidth=1.8, label=f"vid. {m:.3f}: {comps[sel][0]} ({sel.sum()})")
    print(f"mean {m:.3f}: {sel.sum()} trials, median {np.median(T[sel]):.1f} s, range {T[sel].min():.0f}-{T[sel].max():.0f} s")
rest = ~np.isin(means, top)
ax.plot(xs, part(T[rest]), color="0.55", linewidth=1.5, label=f"kitos ({rest.sum()})")
ax.plot(xs, total, color="0.15", linewidth=1.4, linestyle="--", label=f"visos ($n = {SIZE}$)")
for p in peaks:
    ax.axvline(p, color="0.15", linestyle=":", linewidth=1)
ax.set_xlim(0, 320)
ax.set_ylim(bottom=0)
ax.set_xlabel("Reakcijos pabaigos laikas (s)")
ax.set_ylabel("Tankis")
ax.legend(frameon=False, fontsize=8.5, loc="upper right")
fig.savefig(diagrams_dir() / "n4-end-time-by-mean-distance.png", dpi=300)
plt.show()
