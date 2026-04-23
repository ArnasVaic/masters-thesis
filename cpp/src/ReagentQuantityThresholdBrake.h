//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_BRAKE_H
#define YAG_MODEL_BRAKE_H

#include "Discretization.h"
#include "SolverState.h"

namespace yag_model {

class ReagentQuantityThresholdBrake {
    public:
    double threshold;
    double q0;
    size_t step_stride;
    Discretization disc;

    bool shouldBrake(SolverState const& state) const;
};

} // yag_model

#endif //YAG_MODEL_BRAKE_H
