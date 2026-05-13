//
// Created by arnas on 5/1/26.
//

#ifndef YAG_MODEL_STRIDE_CAPTURE_TRIGGER_H
#define YAG_MODEL_STRIDE_CAPTURE_TRIGGER_H
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

#endif  // YAG_MODEL_STRIDE_CAPTURE_TRIGGER_H
