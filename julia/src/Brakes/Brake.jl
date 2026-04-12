abstract type Brake end

should_brake(_::Brake, _::SolverState)::Bool =
    throw(ErrorException("should_brake not implemented for $(typeof(ts))"))
