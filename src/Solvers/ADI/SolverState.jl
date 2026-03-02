export SolverState, init_solver_state

mutable struct SolverState
    curr::SolutionState
    next::SolutionState
    t::Float64
    step::Int
end

function init_solver_state(ic::SolutionState)::SolverState
    return (ic, fill!(similar(ic), 0), 0, 0)
end
