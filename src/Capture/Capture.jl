abstract type Capture end

capture!(_::Capture, _::SolverState)::Nothing = nothing

mutable struct StrideCapture <: Capture
    const stride::Int
    t::Vector{Float64}
    c1::Vector{Matrix{Float64}}
    c2::Vector{Matrix{Float64}}
    c3::Vector{Matrix{Float64}}
end

StrideCapture(stride::Int) = StrideCapture(
    stride, 
    Float64[], 
    Matrix{Float64}[], 
    Matrix{Float64}[], 
    Matrix{Float64}[]
)

function capture!(capture::StrideCapture, state::SolverState)::Nothing

    if state.step % capture.stride != 0
        return nothing
    end

    c1, c2, c3 = state.c

    push!(capture.c1, copy(c1))
    push!(capture.c2, copy(c2))
    push!(capture.c3, copy(c3))
    push!(capture.t, state.time)

    return nothing
end