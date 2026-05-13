//
// Created by arnas on 5/1/26.
//

#include "StrideCaptureTrigger.h"

namespace yag_model {

StrideCaptureTrigger::StrideCaptureTrigger(size_t const stride)
    : stride(stride) {}

bool StrideCaptureTrigger::shouldCapture(SolverState const &state) const {
    return state.step % stride == 0;
}

}  // namespace yag_model
