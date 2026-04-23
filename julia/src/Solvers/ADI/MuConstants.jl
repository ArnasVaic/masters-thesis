struct MuConstants
    x::NTuple{5, Float64}
    y::NTuple{5, Float64}
    mat::Matrix{Float64}
end

function MuConstants(
    rp::ReactionParameters,
    disc::Discretization,
    dt::Float64
)
    mu_x = map(d -> 0.5 * dt / (disc.dx^2) * d, rp.D)
    mu_y = map(d -> 0.5 * dt / (disc.dy^2) * d, rp.D)
    mat = zeros(Float64, 5, 3)

    # Equation 1:
    # -k1 c1 c2 - k2 c1 c3 - k3 c1 c4
    mat[1, 1] = -rp.k[1]
    mat[1, 2] = -rp.k[2]
    mat[1, 3] = -rp.k[3]

    # Equation 2:
    # -2 k1 c1 c2
    mat[2, 1] = -2rp.k[1]

    # Equation 3:
    # k1 c1 c2 - k2 c1 c3
    mat[3, 1] =  rp.k[1]
    mat[3, 2] = -rp.k[2]

    # Equation 4:
    # 4 k2 c1 c3 - 3 k3 c1 c4
    mat[4, 2] =  4rp.k[2]
    mat[4, 3] = -3rp.k[3]

    # Equation 5:
    # k3 c1 c4
    mat[5, 3] = rp.k[3]

    mat .*= 0.5 * dt

    return MuConstants(mu_x, mu_y, mat)
end
