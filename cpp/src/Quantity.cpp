//
// Created by arnas on 4/23/2026.
//

#include "Quantity.h"

namespace yag_model
{
    double quantity(xt::xarray<double> const& c, Discretization const& disc)
    {
        return xt::sum(c)() * disc.dx * disc.dy;
    }

    double reagentQuantity(SolutionState const& state, Discretization const& disc)
    {
        double const q1 = quantity(state.c1, disc);
        double const q2 = quantity(state.c2, disc);
        return q1 + q2;
    }
}
