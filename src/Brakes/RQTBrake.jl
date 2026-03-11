using Printf

"""
Reagent Quantity Threshold Brake

# Arguments
- `t`: reagent quantity threshold
- `q0`: initial reagent quantity
- `step_stride`: will only check to brake every `step_stride` frames
"""
struct RQTBrake <: Brake
    t::Float64
    q0::Float64
    step_stride::Int
end

Base.show(io::IO, brake::RQTBrake) = 
    print(io, "RQTBrake(threshold=$(round(brake.t, digits=2)), q0=$(round(brake.q0, digits=4)), step_stride=$(brake.step_stride))")

function should_brake(brake::RQTBrake, state::SolverState)::Bool
    if state.step % brake.step_stride != 0
        return false
    end

    c1, c2, _ = state.c
    rq = sum(@views c1 .+ c2)
    ratio = rq / brake.q0

    @debug @sprintf(
        "RQTBrake: step=%6d, time=%6.2f hrs, q=%6.5f, ratio=%6.2f",
        state.step,
        state.time / 3600,
        rq,
        ratio
    )

    if ratio <= brake.t
        @debug "RQTBrake: break!"
    end

    return ratio <= brake.t
end
