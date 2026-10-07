#pragma once

#include "Core/SolverState.h"

namespace yag_model {
class ITimeStep {
public:
  virtual ~ITimeStep() = default;

  [[nodiscard]]
  virtual double getTimestep() const = 0;

  virtual void advance(SolverState const& state) = 0;
};

}  // namespace yag_model
