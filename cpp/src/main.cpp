#include <iostream>
#include <xtensor.hpp>

#include "SolutionState.h"

int main() {
  xt::xarray<double> a = {{1, 2}, {3, 4}};
  xt::xarray<double> b = {{10, 20}, {30, 40}};

  auto c = a + b;

  std::cout << c << std::endl;

  auto state = yag_model::SolutionState(10, 10);
  auto shp = state.c[0].shape();
  std::cout << shp[0] << ' ' << shp[1] << std::endl;
  // std::cout << state.c1.size() << std::endl;
}
