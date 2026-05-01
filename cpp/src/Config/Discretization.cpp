//
// Created by arnas on 4/23/2026.
//

#include "Discretization.h"

namespace yag_model {

Discretization::Discretization(double const physical_space_w,
                               double const physical_space_h,
                               size_t const mesh_res_x, size_t const mesh_res_y)
    : physical_space_w(physical_space_w),
      physical_space_h(physical_space_h),
      mesh_res_x(mesh_res_x),
      mesh_res_y(mesh_res_y),
      dx(physical_space_w / static_cast<double>(mesh_res_x - 1)),
      dy(physical_space_h / static_cast<double>(mesh_res_y - 1)) {}

}  // namespace yag_model