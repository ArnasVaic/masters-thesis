#pragma once

#include "../Core/SolverState.h"

namespace yag_model {
class ICaptureTrigger {
public:
  virtual ~ICaptureTrigger() = default;

  [[nodiscard]]
  virtual bool shouldCapture(SolverState const& state) const = 0;
};
}  // namespace yag_model
