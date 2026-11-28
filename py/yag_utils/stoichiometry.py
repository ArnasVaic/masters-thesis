#
# Stoichiometry matrices S (species x reactions, shape (5, 3)) for solver_config
#

import numpy as np
import yag_model

from .constants import MOLAR_MASSES

# YAG synthesis via YAM and YAP intermediates, derived in the thesis
default = yag_model.DEFAULT_STOICHIOMETRY

# Single direct reaction 5 Al2O3 + 3 Y2O3 -> 2 YAG, other reactions disabled
simplified = np.array([
    [-5, 0, 0],
    [-3, 0, 0],
    [ 0, 0, 0],
    [ 0, 0, 0],
    [ 2, 0, 0],
], dtype=float)
simplified.flags.writeable = False

# Al2O3 and Y2O3 formula units in one formula unit of each species (Al2O3, Y2O3, YAM, YAP, YAG):
# YAM = Al2O3 . 2 Y2O3, YAP = (Al2O3 . Y2O3) / 2, YAG = (5 Al2O3 . 3 Y2O3) / 2
OXIDE_UNITS = np.array([
    [1.0, 0.0],
    [0.0, 1.0],
    [1.0, 2.0],
    [0.5, 0.5],
    [2.5, 1.5],
])
OXIDE_UNITS.flags.writeable = False
# Every reaction of the default scheme conserves both oxides
assert np.allclose(OXIDE_UNITS.T @ default, 0)


def y2o3_per_al2o3(mass_percent) -> float:
    """Molar ratio Y2O3 / Al2O3 of the starting mixture a sample with these mass percentages
    of the species (Al2O3, Y2O3, YAM, YAP, YAG) was made from, 3/5 for a stoichiometric one."""
    moles = np.asarray(mass_percent, dtype=float) / np.asarray(MOLAR_MASSES)
    al2o3, y2o3 = moles @ OXIDE_UNITS
    return float(y2o3 / al2o3)
