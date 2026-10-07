#pragma once

#include <xtensor/containers/xarray.hpp>

namespace yag_model {
class Constants {
  static constexpr double O = 15.999;
  static constexpr double Al = 26.982;
  static constexpr double Y = 88.906;

public:
  // Default YAG synthesis stoichiometry matrix
  inline static xt::xarray<double> const S = {
      {-1, -1, -1}, {-2, 0, 0}, {1, -1, 0}, {0, 4, -3}, {0, 0, 1}
  };

  // Molar masses (g/mol) of Al2O3, Y2O3, YAM, YAP, YAG
  inline static xt::xarray<double> const M = {
      2 * Al + 3 * O,
      2 * Y + 3 * O,
      4 * Y + 2 * Al + 9 * O,
      1 * Y + 1 * Al + 3 * O,
      3 * Y + 5 * Al + 12 * O,
  };
};
}  // namespace yag_model
