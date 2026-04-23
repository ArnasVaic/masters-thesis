//
// Created by arnas on 4/23/2026.
//

#include "ReagentQuantityThresholdBrake.h"
#include "Quantity.h"

namespace yag_model
{
    bool ReagentQuantityThresholdBrake::shouldBrake(SolverState const& state) const
    {
        if (state.step % this->step_stride != 0)
        {
            return false;
        }

        double const q = reagentQuantity(state.solution, disc);

        return q / this->q0 <= this->threshold;
    }
} // yag_model