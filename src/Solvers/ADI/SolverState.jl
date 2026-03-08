export SolverState, init_solver_state

mutable struct SolverState
    c::SolutionState
    time::Float64
    step::Int
end

function init_solver_state(ic::SolutionState)::SolverState
    return SolverState(ic, 0, 0)
end
