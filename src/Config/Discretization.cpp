#include "Discretization.h"

#include <stdexcept>

namespace yag_model {

Discretization::Discretization(
    double const physical_space_w,
    double const physical_space_h,
    size_t const mesh_res_x,
    size_t const mesh_res_y
)
    : physical_space_w(physical_space_w),
      physical_space_h(physical_space_h),
      mesh_res_x(mesh_res_x),
      mesh_res_y(mesh_res_y),
      dx(physical_space_w / static_cast<double>(mesh_res_x - 1)),
      dy(physical_space_h / static_cast<double>(mesh_res_y - 1)) {
  if (mesh_res_x < 2 || mesh_res_y < 2) {
    throw std::invalid_argument("Mesh resolution must be at least 2 in each direction");
  }

  if (!(physical_space_w > 0.0) || !(physical_space_h > 0.0)) {
    throw std::invalid_argument("Physical size must be positive");
  }
}

}  // namespace yag_model