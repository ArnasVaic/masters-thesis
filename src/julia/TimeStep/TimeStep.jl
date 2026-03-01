export TimeStep

abstract type TimeStep end

dt(ts::TimeStep)::Float64 =
    throw(ErrorException("dt not implemented for $(typeof(ts))"))

update!(ts::TimeStep, state) = 
    throw(ErrorException("update! not implemented for $(typeof(ts))"))
