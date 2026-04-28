//
// Created by arnas on 4/24/2026.
//

#ifndef YAG_MODEL_FIXED_TIMESTEP_H
#define YAG_MODEL_FIXED_TIMESTEP_H

#include "../SolverState.h"

namespace yag_model {

class FixedTimeStep {
 public:
  double dt;

  explicit FixedTimeStep(double dt);

  [[nodiscard]]
  double getTimestep() const;

  void advance(SolverState const& state);
};

}  // namespace yag_model

#endif  // YAG_MODEL_FIXED_TIMESTEP_H
