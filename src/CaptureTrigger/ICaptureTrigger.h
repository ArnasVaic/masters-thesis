//
// Created by arnas on 4/30/2026.
//

#ifndef YAG_MODEL_ICAPTURETRIGGER_H
#define YAG_MODEL_ICAPTURETRIGGER_H

#include "../Core/SolverState.h"

namespace yag_model {
class ICaptureTrigger {
   public:
    virtual ~ICaptureTrigger() = default;

    [[nodiscard]]
    virtual bool shouldCapture(SolverState const &state) const = 0;
};
}  // namespace yag_model

#endif  // YAG_MODEL_ICAPTURETRIGGER_H
