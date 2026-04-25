//
// Created by arnas on 4/23/2026.
//

#include "StridedCapture.h"

namespace yag_model
{
    inline void StridedCapture::capture(SolverState const& state)
    {
        if (state.step % this->stride != 0)
        {
            return;
        }

        if (this->size >= this->capacity)
        {
            return;
        }

        this->size++;
        this->t_history.push_back(state.time);
        this->c1_history.push_back(state.solution.c1);
        this->c2_history.push_back(state.solution.c2);
        this->c3_history.push_back(state.solution.c3);
        this->c4_history.push_back(state.solution.c4);
        this->c5_history.push_back(state.solution.c5);
    }
}
