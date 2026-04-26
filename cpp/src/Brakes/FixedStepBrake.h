//
// Created by arnas on 4/26/2026.
//

#ifndef YAG_MODEL_FIXEDSTEPBRAKE_H
#define YAG_MODEL_FIXEDSTEPBRAKE_H

#include <cstddef>
#include "SolverState.h"

namespace yag_model
{

class FixedStepBrake
{
public:
    size_t steps;

    FixedStepBrake(size_t const steps);

    bool shouldBrake(SolverState const& state) const;
};

}

#endif //YAG_MODEL_FIXEDSTEPBRAKE_H
