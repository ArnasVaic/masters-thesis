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

    Discretization(
        double const physical_space_w,
        double const physical_space_h,
        size_t const mesh_res_x,
        size_t const mesh_res_y)
    : physical_space_w(physical_space_w)
    , physical_space_h(physical_space_h)
    , mesh_res_x(mesh_res_x)
    , mesh_res_y(mesh_res_y)
    , dx(physical_space_w / static_cast<double>(mesh_res_x - 1))
    , dy(physical_space_h / static_cast<double>(mesh_res_y - 1))
    {

    }
};

} // yag_model

#endif //YAG_MODEL_DISCRETIZATION_H
