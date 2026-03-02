export Checkerboard, build_ic

struct Checkerboard
    grid::Size
    particle::Size
    particle_cnt::Size
    material_concentration::NTuple{2, Float64}

    function Checkerboard(
            grid::Size,
            particle::Size,
            material_concentration::NTuple{2, Float64}
        )

        grid.width % particle.width == 0 ||
            error("required: grid.width % particle.width == 0")

        grid.height % particle.height == 0 ||
            error("required: grid.height % particle.height == 0")

        particle_cnt = grid / particle

        return new(grid, particle, particle_cnt, material_concentration)
    end
end

function build_ic(cfg::Checkerboard)::SolutionState
    ic = empty_solution_state(cfg.grid)
    pw = cfg.particle.width
    ph = cfg.particle.height

    for py in 1:cfg.particle_cnt.height
        for px in 1:cfg.particle_cnt.width

            mat_idx = isodd(px + py) ? 1 : 2

            x_rng = (1 + (px - 1) * pw):(px * pw)
            y_rng = (1 + (py - 1) * ph):(py * ph)

            conc = cfg.material_concentration[mat_idx]

            @views ic[mat_idx][y_rng, x_rng] .= conc
        end
    end

    return ic
end
