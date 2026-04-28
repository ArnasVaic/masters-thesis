//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_QUANTITY_H
#define YAG_MODEL_QUANTITY_H
#include "Discretization.h"
#include "SolutionState.h"

namespace yag_model {
double quantity(xt::xarray<double> const& c, Discretization const& disc);

double reagentQuantity(SolutionState const& state, Discretization const& disc);
}  // namespace yag_model

#endif  // YAG_MODEL_QUANTITY_H
