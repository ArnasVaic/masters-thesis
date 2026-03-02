export SolutionState, empty_solution_state

const SolutionState = NTuple{3, Matrix{Float64}}

function empty_solution_state(size::Size)::SolutionState
    return ntuple(_ -> zeros(size.height, size.width), 3)
end
