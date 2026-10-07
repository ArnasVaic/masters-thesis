#include "Core/SolverState.h"

namespace yag_model {
SolverState::SolverState(size_t const rows, size_t const cols)
    : solution(rows, cols), time(0), step(0) {}

}  // namespace yag_model