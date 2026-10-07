#include "StrideTrigger.h"

namespace yag_model {

StrideTrigger::StrideTrigger(size_t const stride) : stride(stride) {}

bool StrideTrigger::shouldCapture(SolverState const& state) const {
  return state.step % stride == 0;
}

}  // namespace yag_model
