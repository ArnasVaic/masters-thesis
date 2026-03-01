export Discretization

"""

Grid discretization configuration

# Arguments

- `dx :: Float64`: Horizontal spacing between discrete grid points
- `dy :: Float64`: Vertical spacing between discrete grid points
- `grid :: Size`: Size of the grid in discrete points
"""
struct Discretization
    dx::Float64
    dy::Float64
    grid::Size

    function Discretization(dx::Float64, dy::Float64, grid::Size)
        dx > 0 || error("required: dx > 0")
        dy > 0 || error("required: dy > 0")

        return new(dx, dy, grid)
    end
end

DiscretizationConfig(
    sx::Float64,
    sy::Float64,
    nx::Int,
    ny::Int
) = DiscretizationConfig(
    sx / (nx - 1),
    sy / (ny - 1),
    nx,
    ny
)
