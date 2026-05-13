#include <catch2/catch_test_macros.hpp>
#include <xtensor.hpp>

TEST_CASE("xtensor basic test") {
    xt::xarray<int> arr = {1, 2, 3};
    REQUIRE(arr.size() == 3);
}