#pragma once

#include "ICaptureTrigger.h"

namespace yag_model {
class StrideCaptureTrigger : public ICaptureTrigger {
   public:
    size_t stride;

    explicit StrideCaptureTrigger(size_t stride);

    [[nodiscard]]
    bool shouldCapture(SolverState const &state) const override;
};
}  // namespace yag_model
