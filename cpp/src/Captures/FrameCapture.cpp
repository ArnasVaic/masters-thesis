//
// Created by arnas on 4/23/2026.
//

#include "Captures/FrameCapture.h"

namespace yag_model
{
    FrameCapture::FrameCapture(size_t const capacity, size_t const stride)
    : stride(stride)
    , capacity(capacity)
    {
        assert(stride > 0);
        t_history.reserve(capacity);
        for (auto& species_history : c_history)
        {
            species_history.reserve(capacity);
        }
    }

    inline void FrameCapture::capture(SolverState const& state)
    {
        if (state.step % stride != 0)
            return;

        if (t_history.size() >= capacity)
            return;

        t_history.push_back(state.time);

        for (size_t mat = 0; mat < state.solution.c.size(); ++mat)
        {
            c_history[mat].push_back(state.solution.c[mat]);
        }
    }
}
