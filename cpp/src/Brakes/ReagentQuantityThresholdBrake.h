//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_BRAKE_H
#define YAG_MODEL_BRAKE_H

#include "../Config/Discretization.h"
#include "../Core/SolverState.h"
#include "IBrake.h"

namespace yag_model {

class ReagentQuantityThresholdBrake : public IBrake {
   public:
    double threshold;
    double initial_reagent_quantity;
    size_t stride;
    Discretization disc;

    ReagentQuantityThresholdBrake(double threshold,
        double initial_reagent_quantity,
        size_t stride,
        Discretization const& disc);

    [[nodiscard]]
    bool shouldBrake(SolverState const& state) const;
};

}  // namespace yag_model

#endif  // YAG_MODEL_BRAKE_H
