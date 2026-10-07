#pragma once

#include "Core/SolverContext.h"
#include "Core/SolverState.h"

namespace yag_model {
class ITrigger {
public:
  virtual ~ITrigger() = default;

  // Called once before the first step, resets any internal state
  virtual void begin(SolverContext const& ctx) {}

  [[nodiscard]]
  virtual bool shouldCapture(SolverState const& state) const = 0;
};
}  // namespace yag_model
