#pragma once

#include "Core/SolverContext.h"
#include "Core/SolverState.h"

namespace yag_model {
class ITimeStep {
public:
  virtual ~ITimeStep() = default;

  // Called once before the first step, resets any internal state
  virtual void begin(SolverContext const& ctx) {}

  // Called before every step, returns the timestep to advance the state by
  virtual double advance(SolverState const& state) = 0;
};

}  // namespace yag_model
