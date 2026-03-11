"""
# Arguments
- `D :: NTuple{3, Float64}`: Diffusion coefficients for each element
- `alpha :: NTuple{3, Float64}`: Reaction coefficients
- `k :: Float64`: Reaction speed
"""
struct ReactionParameters
    D::NTuple{3, Float64}
    alpha::NTuple{3, Float64}
    k::Float64

    function ReactionParameters(
            D::NTuple{3, Float64},
            alpha::NTuple{3, Float64},
            k::Float64
        )
        all(D .>= 0) || error("All diffusion coefficients must not be negative")
        k >= 0 || error("Reaction speed constant must be non negative")
        return new(D, alpha, k)
    end
end
