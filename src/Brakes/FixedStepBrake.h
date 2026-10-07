#pragma once

#include "IBrake.h"

namespace yag_model {

class FixedStepBrake : public IBrake {
public:
  size_t last_step;

  explicit FixedStepBrake(size_t last_step);

  [[nodiscard]]
  bool shouldBrake(SolverState const& state) const override;
};

}  // namespace yag_model
