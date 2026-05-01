//
// Created by arnas on 4/23/2026.
//

#include "ReagentQuantityThresholdBrake.h"

#include "Core/Quantity.h"

namespace yag_model {

ReagentQuantityThresholdBrake::ReagentQuantityThresholdBrake(
    double const threshold,
    double const initial_reagent_quantity,
    size_t const stride,
    Discretization const& disc)
    : threshold(threshold),
      initial_reagent_quantity(initial_reagent_quantity),
      stride(stride),
      disc(disc) {}

inline bool ReagentQuantityThresholdBrake::shouldBrake(
    SolverState const& state) const {
    if (state.step % stride != 0) {
        return false;
    }

    double const q = reagentQuantity(state.solution, disc);

    return q / initial_reagent_quantity <= threshold;
}

}  // namespace yag_model