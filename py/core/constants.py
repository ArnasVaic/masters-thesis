#
# Constants related to YAG model
#

import numpy as np

# Experimental data, element percentage by mass after 6hrs at 1400C
P_TRUE = np.array([ 29.21, 19.37, 15.08, 24.06, 12.27])

OXYGEN_ATOMIC_WEIGHT = 15.999
ALUMINUM_ATOMIC_WEIGHT = 26.982
YTTRIUM_ATOMIC_WEIGHT = 88.906

# Molar masses of elements within synthesis
MOLAR_MASSES = np.array([ 
    # Al2 O3
    2 * ALUMINUM_ATOMIC_WEIGHT +
    3 * OXYGEN_ATOMIC_WEIGHT,

    # Y2 O3
    2 * YTTRIUM_ATOMIC_WEIGHT +
    3 * OXYGEN_ATOMIC_WEIGHT,

    # Y4 Al2 O9 (YAM)
    4 * YTTRIUM_ATOMIC_WEIGHT +
    2 * ALUMINUM_ATOMIC_WEIGHT +
    9 * OXYGEN_ATOMIC_WEIGHT,

    # Y Al O3 (YAP)
    1 * YTTRIUM_ATOMIC_WEIGHT +
    1 * ALUMINUM_ATOMIC_WEIGHT +
    3 * OXYGEN_ATOMIC_WEIGHT,
    
    # Y3 Al5 O12 (YAG)
    3 * YTTRIUM_ATOMIC_WEIGHT +
    5 * ALUMINUM_ATOMIC_WEIGHT +
    12 * OXYGEN_ATOMIC_WEIGHT,
])

# YAG synthesis reaction stoichiometry matrix
S = np.array([
    [-1, -1, -1],
    [-2,  0,  0],
    [ 1, -1,  0],
    [ 0,  4, -3],
    [ 0,  0,  1]
])