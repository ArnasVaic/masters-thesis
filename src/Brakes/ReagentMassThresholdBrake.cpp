#include "ReagentMassThresholdBrake.h"

#include "Core/Quantity.h"

namespace yag_model {

ReagentMassThresholdBrake::ReagentMassThresholdBrake(
    double const threshold, size_t const stride
)
    : threshold(threshold), stride(stride), initial_reagent_mass(0.0) {}

void ReagentMassThresholdBrake::begin(SolverContext const& ctx) {
  disc = ctx.disc;
  initial_reagent_mass = reagentMass(ctx.initial, ctx.disc);
}

bool ReagentMassThresholdBrake::shouldBrake(SolverState const& state) const {
  if (state.step % stride != 0) {
    return false;
  }

  double const m = reagentMass(state.solution, *disc);

  return m / initial_reagent_mass <= threshold;
}

}  // namespace yag_model
