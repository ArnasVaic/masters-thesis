//
// Created by arnas on 4/25/2026.
//

#ifndef YAG_MODEL_MU_COEFFICIENTS_H
#define YAG_MODEL_MU_COEFFICIENTS_H

#include <xtensor.hpp>

#include "Discretization.h"
#include "ModelParameters.h"

namespace yag_model
{

struct MuCoefficients
{
    xt::xarray<double> x = xt::zeros<double>({5});
    xt::xarray<double> y = xt::zeros<double>({5});

    void initialize(Discretization const& disc,
        ModelParameters const& params,
        double const dt)
    {
        x = 0.5 * dt * params.D / (disc.dx * disc.dx);
        y = 0.5 * dt * params.D / (disc.dy * disc.dy);
    }
};

}

#endif //YAG_MODEL_MU_COEFFICIENTS_H
