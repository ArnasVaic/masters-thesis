//
// Created by arnas on 4/26/2026.
//

#ifndef YAG_MODEL_FIXED_STEP_BRAKE_H
#define YAG_MODEL_FIXED_STEP_BRAKE_H

#include "Core/SolverState.h"
#include "IBrake.h"

namespace yag_model {

class FixedStepBrake : public IBrake {
   public:
    size_t steps;

    explicit FixedStepBrake(size_t steps);

    [[nodiscard]]
    bool shouldBrake(SolverState const& state) const override;
};

}  // namespace yag_model

#endif  // YAG_MODEL_FIXED_STEP_BRAKE_H
