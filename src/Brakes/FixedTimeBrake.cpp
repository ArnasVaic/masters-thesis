#include "FixedTimeBrake.h"

namespace yag_model {

FixedTimeBrake::FixedTimeBrake(double const final_time) : final_time(final_time) {}

bool FixedTimeBrake::shouldBrake(SolverState const& state) const {
  return final_time <= state.time;
}

}  // namespace yag_model
