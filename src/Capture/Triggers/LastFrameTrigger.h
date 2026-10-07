#pragma once

#include "ITrigger.h"

namespace yag_model {

// Captures only the state the solver marked as final
class LastFrameTrigger : public ITrigger {
public:
  [[nodiscard]]
  bool shouldCapture(SolverState const& state) const override;
};

}  // namespace yag_model
