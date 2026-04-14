#include <xtensor.hpp>
#include <iostream>

int main() {
    xt::xarray<double> a = {{1, 2}, {3, 4}};
    xt::xarray<double> b = {{10, 20}, {30, 40}};

    auto c = a + b;

    std::cout << c << std::endl;
}