#include <iostream>
#include <xtensor.hpp>

#include "Brakes/FixedTimeBrake.h"
#include "Capture/Reducers/MolarQuantityReducer.h"
#include "Capture/Sinks/InMemorySink.h"
#include "Capture/Triggers/StrideTrigger.h"
#include "Config/Discretization.h"
#include "Config/ModelParameters.h"
#include "Core/SolutionState.h"
#include "InitialCondition/CheckerboardInitialCondition.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"

int main() {
  // -----------------------------------------------------------------
  // YAG reaction stoichiometry
  // -----------------------------------------------------------------

  xt::xarray<double> const S = {{-1, -1, -1}, {-2, 0, 0}, {1, -1, 0}, {0, 4, -3}, {0, 0, 1}};

  yag_model::ModelParameters params({1e-6, 1e-6, 1e-6, 1e-6, 1e-6}, {1e6, 1e6, 1e6});

  // -----------------------------------------------------------------
  // Scaling constants (same as Python)
  // -----------------------------------------------------------------

  constexpr double D_ref = 1e-4;
  constexpr double L0 = 1.0;  // um
  constexpr double T0 = L0 * L0 / D_ref;
  constexpr double C0 = 3.91e-14;

  // -----------------------------------------------------------------
  // Dimensionless parameters
  // -----------------------------------------------------------------

  yag_model::ModelParameters params_nd = params;

  for (auto& D : params_nd.D) {
    D /= D_ref;
  }

  for (auto& K : params_nd.K) {
    K *= C0 * T0;
  }

  // -----------------------------------------------------------------
  // Dimensionless discretization
  // -----------------------------------------------------------------

  yag_model::Discretization disc(1.0 / L0, 1.0 / L0, 40, 40);

  // -----------------------------------------------------------------
  // Initial condition
  // -----------------------------------------------------------------

  auto ic = yag_model::buildCheckerboardInitialCondition(disc, 1.0, 3.0 / 5.0);

  // -----------------------------------------------------------------
  // Time stepping
  // -----------------------------------------------------------------

  yag_model::SolverConfig config;
  config.discretization = disc;

  double const dt = 6.0 / T0;  // exactly as Python
  config.step = std::make_shared<yag_model::FixedTimeStep>(dt);

  // 6 hours in dimensionless time
  double const t_end = 6.0 * 60.0 * 60.0 / T0;
  config.brake = std::make_shared<yag_model::FixedTimeBrake>(t_end);

  // Capture molar quantities every 10 steps, keep up to 400 frames
  config.capture.trigger = std::make_shared<yag_model::StrideTrigger>(10);
  config.capture.reducer = std::make_shared<yag_model::MolarQuantityReducer>();
  config.capture.sink = std::make_shared<yag_model::InMemorySink>(400);
  config.stoichiometry = S;

  auto const result = yag_model::solve(config, ic, params_nd);
  std::cout << "Captured " << result->size() << " frames\n";
}
