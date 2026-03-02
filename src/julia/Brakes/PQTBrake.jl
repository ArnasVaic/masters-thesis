"""
Product Quantity Threshold Brake

# Arguments
- `t`: product quantity threshold
- `q0`: initial product quantity
- `step_stride`: will only check to brake every `step_stride` frames
"""
struct PQTBrake
    t::Float64
    q0::Float64
    step_stride::Int
end

function should_brake(brake::PQTBrake, state::SolverState)::Bool
    if state.step % brake.step_stride == 0
        return false
    end

    return sum(state.curr) / brake.q0 <= brake.t
end
