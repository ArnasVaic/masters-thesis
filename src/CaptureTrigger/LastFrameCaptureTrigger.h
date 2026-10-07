#pragma once

#include "Brakes/IBrake.h"
#include "ICaptureTrigger.h"

namespace yag_model {

class LastFrameCaptureTrigger : public ICaptureTrigger {
public:
  std::shared_ptr<IBrake> brake;

  LastFrameCaptureTrigger(std::shared_ptr<IBrake> brake);

  [[nodiscard]]
  bool shouldCapture(SolverState const& state) const override;
};

}  // namespace yag_model
