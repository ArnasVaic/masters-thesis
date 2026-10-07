#pragma once

#include "Core/SolverState.h"
#include "IBrake.h"

namespace yag_model {

class FixedStepBrake : public IBrake {
public:
  size_t steps;

  explicit FixedStepBrake(size_t steps);

  [[nodiscard]]
  bool shouldBrake(SolverState const& state) const override;
};

}  // namespace yag_model
