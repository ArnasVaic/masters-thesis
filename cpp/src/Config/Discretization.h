//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_DISCRETIZATION_H
#define YAG_MODEL_DISCRETIZATION_H

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

#endif  // YAG_MODEL_DISCRETIZATION_H
