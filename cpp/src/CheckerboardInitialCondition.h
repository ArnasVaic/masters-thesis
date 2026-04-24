//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_CHECKERBOARD_INITIAL_CONDITION_H
#define YAG_MODEL_CHECKERBOARD_INITIAL_CONDITION_H

#include "SolutionState.h"
#include "Discretization.h"

namespace yag_model
{
    SolutionState buildCheckerboardInitialCondition(
        Discretization const& disc,
        double c1_initial_concentration,
        double c2_initial_concentration
    );
}

#endif //YAG_MODEL_CHECKERBOARD_INITIAL_CONDITION_H
