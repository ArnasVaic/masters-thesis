#pragma once

#include <optional>

#include "Config/Discretization.h"
#include "IBrake.h"

namespace yag_model {

// Brakes once the reagent mass drops to the given fraction of the initial one
class ReagentMassThresholdBrake : public IBrake {
public:
  double threshold;
  size_t stride;

  // Computed from the initial condition in begin()
  double initial_reagent_mass;

  ReagentMassThresholdBrake(double threshold, size_t stride);

  void begin(SolverContext const& ctx) override;

  [[nodiscard]]
  bool shouldBrake(SolverState const& state) const override;

private:
  std::optional<Discretization> disc;
};

}  // namespace yag_model
