export MuConstants

struct MuConstants
    x::NTuple{3, Float64}
    y::NTuple{3, Float64}
    m::NTuple{3, Float64}
end

MuConstants(
    phys::ReactionParameters,
    disc::Discretization,
    dt::Float64
) =
    MuConstants(
    map(a -> 0.5 * dt * phys.k * a, phys.alpha),
    map(d -> 0.5 * dt / disc.dx^2 * d, phys.D),
    map(d -> 0.5 * dt / disc.dy^2 * d, phys.D)
)
