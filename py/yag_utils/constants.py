#
# Constants related to YAG model
#

import numpy as np
import yag_model

# Experimental data, element percentage by mass after 6hrs at 1400C
P_TRUE = np.array([29.21, 19.37, 15.08, 24.06, 12.27])

# Molar masses (g/mol) of Al2O3, Y2O3, YAM, YAP, YAG, defined once in the C++ core
MOLAR_MASSES = yag_model.MOLAR_MASSES
