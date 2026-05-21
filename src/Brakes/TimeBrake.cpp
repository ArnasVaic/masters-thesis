//
// Created by arnas on 5/2/26.
//

#include "TimeBrake.h"

namespace yag_model {

TimeBrake::TimeBrake(double const t_end) : t_end(t_end) {}

bool TimeBrake::shouldBrake(SolverState const& state) const {
    return t_end <= state.time;
}

}  // namespace yag_model