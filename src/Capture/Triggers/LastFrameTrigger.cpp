#include "LastFrameTrigger.h"

namespace yag_model {

bool LastFrameTrigger::shouldCapture(SolverState const& state) const {
  return state.is_final;
}

}  // namespace yag_model
