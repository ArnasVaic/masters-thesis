#pragma once

#include <memory>
#include <xtensor/containers/xarray.hpp>

#include "Brakes/FixedStepBrake.h"
#include "Brakes/IBrake.h"
#include "Config/CaptureConfig.h"
#include "Config/Discretization.h"
#include "Core/Constants.h"
#include "TimeStep/FixedTimeStep.h"
#include "TimeStep/ITimeStep.h"

namespace yag_model {

struct SolverConfig {
  Discretization discretization{1.0, 1.0, 40, 40};
  std::shared_ptr<ITimeStep> step = std::make_shared<FixedTimeStep>(1.0);
  std::shared_ptr<IBrake> brake = std::make_shared<FixedStepBrake>(100);
  CaptureConfig capture;

  // Species x reactions stoichiometry matrix, (5, 3)
  xt::xarray<double> stoichiometry = Constants::S;
};

}  // namespace yag_model
