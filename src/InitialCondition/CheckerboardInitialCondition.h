#pragma once

#include "Config/Discretization.h"
#include "Core/SolutionState.h"

namespace yag_model {
SolutionState buildCheckerboardInitialCondition(Discretization const& disc,
    double c1_initial_concentration,
    double c2_initial_concentration);
}
