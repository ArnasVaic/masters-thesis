//
// Created by arnas on 4/24/2026.
//

#include <catch2/catch_test_macros.hpp>

#include "../src/CheckerboardInitialCondition.h"

TEST_CASE("Checkerboard initial condition", "[initial_condition]")
{
    yag_model::Discretization disc(1.0, 1.0, 4, 4);
    auto state = yag_model::buildCheckerboardInitialCondition(
        disc, 1.0, 2.0);

    REQUIRE(xt::allclose(state.c[0], xt::xarray<double>(
        {
            {1.0, 1.0, 0.0, 0.0},
            {1.0, 1.0, 0.0, 0.0},
            {0.0, 0.0, 1.0, 1.0},
            {0.0, 0.0, 1.0, 1.0}
        }
    )));

    REQUIRE(xt::allclose(state.c[1], xt::xarray<double>(
        {
            {0.0, 0.0, 2.0, 2.0},
            {0.0, 0.0, 2.0, 2.0},
            {2.0, 2.0, 0.0, 0.0},
            {2.0, 2.0, 0.0, 0.0}
        }
    )));
}