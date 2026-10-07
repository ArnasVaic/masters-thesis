#pragma once

#include "../Core/SolverState.h"
#include "ITimeStep.h"

namespace yag_model {

class FixedTimeStep : public ITimeStep {
public:
  double dt;

  explicit FixedTimeStep(double dt);

  [[nodiscard]]
  double getTimestep() const override;

  void advance(SolverState const& state) override;
};

}  // namespace yag_model
