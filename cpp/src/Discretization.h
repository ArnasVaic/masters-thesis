//
// Created by arnas on 4/23/2026.
//

#ifndef YAG_MODEL_DISCRETIZATION_H
#define YAG_MODEL_DISCRETIZATION_H

#include <cstddef>

namespace yag_model {

class Discretization {
    public:
    double dx;
    double dy;

    // double physical_w;
    // double physical_h;
    //
    // size_t mesh_res_x;
    // size_t mesh_res_y;
    //
    // size_t particle_cnt_x;
    // size_t particle_cnt_y;
    //
    // size_t particle_res_x;
    // size_t particle_res_y;

    Discretization(
        double const physical_space_w,
        double const physical_space_h,
        size_t const mesh_res_x,
        size_t const mesh_res_y)
    : dx(physical_space_w / (mesh_res_x - 1))
    , dy(physical_space_h / (mesh_res_y - 1))
    {

    }
};

} // yag_model

#endif //YAG_MODEL_DISCRETIZATION_H
