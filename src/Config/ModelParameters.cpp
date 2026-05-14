//
// Created by arnas on 4/23/2026.
//

#include "Config/ModelParameters.h"
yag_model::ModelParameters::ModelParameters(
    xt::xarray<double> const& D, xt::xarray<double> const& K)
    : D(D), K(K) {}