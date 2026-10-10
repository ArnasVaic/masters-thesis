#
# Stoichiometry matrices S (species x reactions, shape (5, 3)) for solver_config
#

import numpy as np
import yag_model

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
