#include "ReagentQuantityThresholdBrake.h"

#include "Core/Quantity.h"

namespace yag_model {

ReagentQuantityThresholdBrake::ReagentQuantityThresholdBrake(
    double const threshold, size_t const stride
)
    : threshold(threshold), stride(stride), initial_reagent_quantity(0.0) {}

void ReagentQuantityThresholdBrake::begin(SolverContext const& ctx) {
  disc = ctx.disc;
  initial_reagent_quantity = reagentQuantity(ctx.initial, ctx.disc);
}

bool ReagentQuantityThresholdBrake::shouldBrake(SolverState const& state) const {
  if (state.step % stride != 0) {
    return false;
  }

  double const q = reagentQuantity(state.solution, *disc);

  return q / initial_reagent_quantity <= threshold;
}

}  // namespace yag_model
