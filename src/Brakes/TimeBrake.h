#pragma once

#include "IBrake.h"

namespace yag_model {

class TimeBrake : public IBrake {
   public:
    double t_end;

    explicit TimeBrake(double t_end);

    [[nodiscard]]
    bool shouldBrake(SolverState const& state) const override;
};

}  // namespace yag_model
