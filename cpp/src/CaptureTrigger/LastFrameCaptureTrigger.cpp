//
// Created by arnas on 5/2/26.
//

#include "LastFrameCaptureTrigger.h"

#include <utility>

namespace yag_model {

LastFrameCaptureTrigger::LastFrameCaptureTrigger(std::shared_ptr<IBrake> brake)
    : brake(std::move(brake)) {}

bool LastFrameCaptureTrigger::shouldCapture(SolverState const& state) const {
    return brake->shouldBrake(state);
}

}  // namespace yag_model