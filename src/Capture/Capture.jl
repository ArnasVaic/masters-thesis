export Capture, EveryNCapture, capture!

abstract type Capture end

capture!(_::Capture, _::SolverState)::Nothing = nothing

struct EveryNCapture
    n::Int
    frames::Vector{SolutionState}
end

