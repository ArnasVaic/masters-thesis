//
// Created by arnas on 4/30/2026.
//

#ifndef YAG_MODEL_ITIMESTEP_H
#define YAG_MODEL_ITIMESTEP_H
#include "../Core/SolverState.h"

namespace yag_model {
class ITimeStep {
   public:
    virtual ~ITimeStep() = default;
    [[nodiscard]]
    double getTimestep() const;

    void advance(SolverState const& state);
};

}  // namespace yag_model

#endif  // YAG_MODEL_ITIMESTEP_H
