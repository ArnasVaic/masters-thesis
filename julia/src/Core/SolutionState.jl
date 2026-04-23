using StaticArrays

const SolutionState = NTuple{5, Matrix{Float64}}

function empty_solution_state(size::SVector{2, Int})::SolutionState
    w, h = size
    return ntuple(_ -> zeros(Float64, h, w), 5)
end
