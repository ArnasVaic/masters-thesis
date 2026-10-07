#pragma once

#include "../Config/Discretization.h"
#include "SolutionState.h"
#include "SolverState.h"

namespace yag_model {

double quantity(xt::xarray<double> const& c, Discretization const& disc);

double reagentQuantity(SolutionState const& state, Discretization const& disc);

}  // namespace yag_model
