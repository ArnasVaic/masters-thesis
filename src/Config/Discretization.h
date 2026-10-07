#pragma once

#include <cstddef>

namespace yag_model {

class Discretization {
 public:
  double physical_space_w;
  double physical_space_h;
  size_t mesh_res_x;
  size_t mesh_res_y;
  double dx;
  double dy;
  Discretization(double physical_space_w, double physical_space_h,
                 size_t mesh_res_x, size_t mesh_res_y);
};

}  // namespace yag_model
