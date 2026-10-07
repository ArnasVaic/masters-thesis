#pragma once

#include "../Core/SolverState.h"

namespace yag_model {

class IBrake {
   public:
    virtual ~IBrake() = default;

    [[nodiscard]]
    virtual bool shouldBrake(SolverState const& state) const = 0;
};

}  // namespace yag_model
