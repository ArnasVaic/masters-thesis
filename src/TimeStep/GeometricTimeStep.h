#pragma once

#include "ITimeStep.h"

namespace yag_model {

// Timestep growing geometrically: dt_n = dt_0 * r^n
class GeometricTimeStep : public ITimeStep {
public:
  double dt_0;
  double r;

  GeometricTimeStep(double dt_0, double r);

  void begin(SolverContext const& ctx) override;

  double advance(SolverState const& state) override;

private:
  double dt;
};

}  // namespace yag_model
