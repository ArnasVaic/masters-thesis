#pragma once

#include "ITimeStep.h"

namespace yag_model {

class FixedTimeStep : public ITimeStep {
public:
  double dt;

  explicit FixedTimeStep(double dt);

  double advance(SolverState const& state) override;
};

}  // namespace yag_model
