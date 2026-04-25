//
// Created by arnas on 4/24/2026.
//

#include "FixedTimeStep.h"

namespace yag_model
{
    inline double FixedTimeStep::getTimestep() const
    {
        return this->dt;
    }

    inline void FixedTimeStep::advance(SolverState const& state)
    {

    }
} // yag_model