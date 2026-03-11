struct MuConstants
    x::NTuple{3, Float64}
    y::NTuple{3, Float64}
    m::NTuple{3, Float64}
end

MuConstants(
    rp::ReactionParameters,
    disc::Discretization,
    dt::Float64
) =
    MuConstants(
    map(d -> 0.5 * dt / (disc.dx^2) * d, rp.D),
    map(d -> 0.5 * dt / (disc.dy^2) * d, rp.D),
    map(a -> 0.5 * dt * rp.k * a, rp.alpha)
)
