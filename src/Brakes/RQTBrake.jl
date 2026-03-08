export RQTBrake, should_brake

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

function should_brake(brake::RQTBrake, state::SolverState)::Bool
    if state.step % brake.step_stride != 0
        return false
    end

    c1, c2, _ = state.c
    rq = sum(@views c1 .+ c2)
    ratio = rq / brake.q0
    
    # println("brake: ", ratio <= brake.t, ", r: ", round(ratio, digits=2), ", step:", state.step, ", t: ", state.t)

    @debug "step=$(state.step), time=$(state.time), q0=$(brake.q0), q=$(rq), ratio=$(round(ratio, digits=2))"

    return ratio <= brake.t
end
