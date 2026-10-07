#pragma once

#include "ITrigger.h"

namespace yag_model {
class StrideTrigger : public ITrigger {
public:
  size_t stride;

  explicit StrideTrigger(size_t stride);

  [[nodiscard]]
  bool shouldCapture(SolverState const& state) const override;
};
}  // namespace yag_model
