#pragma once

#include "Core/SolverState.h"

namespace yag_model {

class ICapture {
   public:
    virtual ~ICapture() = default;
    virtual void capture(SolverState const& state) = 0;
};

}  // namespace yag_model
