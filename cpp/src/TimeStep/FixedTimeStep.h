//
// Created by arnas on 4/24/2026.
//

#ifndef YAG_MODEL_FIXED_TIMESTEP_H
#define YAG_MODEL_FIXED_TIMESTEP_H

#include "../Core/SolverState.h"
#include "ITimeStep.h"

namespace yag_model {

class FixedTimeStep : public ITimeStep {
   public:
    double dt;

    explicit FixedTimeStep(double dt);

    [[nodiscard]]
    double getTimestep() const override;

    void advance(SolverState const& state) override;
};

}  // namespace yag_model

#endif  // YAG_MODEL_FIXED_TIMESTEP_H
