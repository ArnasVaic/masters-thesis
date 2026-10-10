#include "Config/ModelParameters.h"
yag_model::ModelParameters::ModelParameters(
    xt::xarray<double> const& D, xt::xarray<double> const& k
)
    : D(D), k(k) {}
