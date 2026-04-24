//
// Created by arnas on 4/23/2026.
//

#include "CheckerboardInitialCondition.h"

namespace yag_model
{
    SolutionState buildCheckerboardInitialCondition(
        Discretization const& disc,
        double const c1_initial_concentration,
        double const c2_initial_concentration)
    {
        SolutionState state(disc.mesh_res_y, disc.mesh_res_x);

        assert(disc.mesh_res_x % 2 == 0);
        assert(disc.mesh_res_y % 2 == 0);

        xt::view(
            state.c1,
            xt::range(0,disc.mesh_res_y / 2),
            xt::range(0,disc.mesh_res_x / 2)
        ) = c1_initial_concentration;

        xt::view(
            state.c1,
            xt::range(disc.mesh_res_y / 2,  _),
            xt::range(disc.mesh_res_x / 2, _)
        ) = c1_initial_concentration;

        xt::view(
            state.c2,
            xt::range(0,disc.mesh_res_y / 2),
            xt::range(disc.mesh_res_x / 2, _)
        ) = c2_initial_concentration;

        xt::view(
            state.c2,
            xt::range(disc.mesh_res_y / 2, _),
            xt::range(0, disc.mesh_res_x / 2)
        ) = c2_initial_concentration;

        return state;
    }
}
