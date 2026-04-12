abstract type Capture end

capture!(_::Capture, _::SolverState)::Nothing = nothing

mutable struct StrideCapture <: Capture
    stride::Int
    capacity::Int
    len::Int
    t::Vector{Float64}
    c1::Vector{Matrix{Float64}}
    c2::Vector{Matrix{Float64}}
    c3::Vector{Matrix{Float64}}
end

function StrideCapture(stride::Int, capacity::Int, disc::Discretization)

    w, h = disc.resolution
    c1 = [Matrix{Float64}(undef, h, w) for _ in 1:capacity]
    c2 = [Matrix{Float64}(undef, h, w) for _ in 1:capacity]
    c3 = [Matrix{Float64}(undef, h, w) for _ in 1:capacity]

    StrideCapture(
        stride,
        capacity,
        0,
        Vector{Float64}(undef, capacity),
        c1, 
        c2, 
        c3
    )
end

function capture!(capture::StrideCapture, state::SolverState)::Nothing

    if state.step % capture.stride != 0
        return nothing
    end

    if capture.len >= capture.capacity
        return nothing
    end

    @debug "capture step=$(state.step), time=$(state.time)"

    i = capture.len + 1
    capture.len = i

    capture.t[i] = state.time

    copyto!(capture.c1[i], state.c[1])
    copyto!(capture.c2[i], state.c[2])
    copyto!(capture.c3[i], state.c[3])

    return nothing
end