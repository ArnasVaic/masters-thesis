//
// Created by arnas on 4/30/2026.
//

#ifndef YAG_MODEL_IBRAKE_H
#define YAG_MODEL_IBRAKE_H

#include "../Core/SolverState.h"

namespace yag_model {

class IBrake {
   public:
    virtual ~IBrake() = default;

    [[nodiscard]]
    virtual bool shouldBrake(SolverState const& state) const = 0;
};

}  // namespace yag_model

#endif  // YAG_MODEL_IBRAKE_H
