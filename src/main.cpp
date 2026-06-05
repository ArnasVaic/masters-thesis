#include <iostream>
#include <xtensor.hpp>

#include "Brakes/FixedStepBrake.h"
#include "Brakes/TimeBrake.h"
#include "CaptureTrigger/LastFrameCaptureTrigger.h"
#include "CaptureTrigger/StrideCaptureTrigger.h"
#include "Captures/QuantityCapture.h"
#include "Config/Discretization.h"
#include "Config/ModelParameters.h"
#include "Core/SolutionState.h"
#include "InitialCondition/CheckerboardInitialCondition.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"

int main() {

    yag_model::ModelParameters params(
        {1e-6, 1e-6, 1e-6, 1e-6, 1e-6},
        {1e6, 1e6, 1e6}
    );

    // -----------------------------------------------------------------
    // Scaling constants (same as Python)
    // -----------------------------------------------------------------

    constexpr double D_ref = 1e-4;
    constexpr double L0 = 1.0;       // um
    constexpr double T0 = L0 * L0 / D_ref;
    constexpr double C0 = 3.91e-14;

    // -----------------------------------------------------------------
    // Dimensionless parameters
    // -----------------------------------------------------------------

    yag_model::ModelParameters params_nd = params;

    for (auto& D : params_nd.D)
        D /= D_ref;

    for (auto& K : params_nd.K)
        K *= C0 * T0;

    // -----------------------------------------------------------------
    // Dimensionless discretization
    // -----------------------------------------------------------------

    yag_model::Discretization disc(
        1.0 / L0,
        1.0 / L0,
        40,
        40
    );

    // -----------------------------------------------------------------
    // Initial condition
    // -----------------------------------------------------------------

    auto ic = yag_model::buildCheckerboardInitialCondition(
        disc,
        1.0,
        3.0 / 5.0
    );

    // -----------------------------------------------------------------
    // Time stepping
    // -----------------------------------------------------------------

    double const dt = 6.0 / T0;      // exactly as Python
    yag_model::FixedTimeStep step(dt);

    // 6 hours in dimensionless time
    double const t_end = 6.0 * 60.0 * 60.0 / T0;

    auto brake =
        std::make_shared<yag_model::TimeBrake>(t_end);

    // Capture only final frame
    yag_model::StrideCaptureTrigger captureTrigger(10);

    // Storage for one frame
    yag_model::QuantityCapture capture(400, disc);

    yag_model::solve(
        disc,
        params_nd,
        step,
        *brake,
        captureTrigger,
        capture,
        ic
    );
}
