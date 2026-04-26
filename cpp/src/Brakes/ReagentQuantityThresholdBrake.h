//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_BRAKE_H
#define YAG_MODEL_BRAKE_H

#include "../Discretization.h"
#include "../SolverState.h"

namespace yag_model {

class ReagentQuantityThresholdBrake {
    public:
    double threshold;
    double initial_reagent_quantity;
    size_t stride;
    Discretization disc;

    ReagentQuantityThresholdBrake(
        double threshold,
        double initial_reagent_quantity,
        size_t stride,
        Discretization const& disc
    );

    bool shouldBrake(SolverState const& state) const;
};

} // yag_model

#endif //YAG_MODEL_BRAKE_H
