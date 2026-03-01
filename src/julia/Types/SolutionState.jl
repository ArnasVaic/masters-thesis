export SolutionState, empty_solution_state

const SolutionState = NTuple{3, Matrix{Float64}}

function empty_solution_state(size::Size)::SolutionState
    return (
        zeros(size.width, size.height),
        zeros(size.width, size.height),
        zeros(size.width, size.height),
    )
end
