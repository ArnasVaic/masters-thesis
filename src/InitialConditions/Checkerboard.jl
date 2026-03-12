function build_checkerboard_ic(
    disc::Discretization, 
    c1::Float64, 
    c2::Float64)::SolutionState

    ic = empty_solution_state(disc.resolution)
    pw, ph = disc.particle_resolution
    pnx, pny = disc.particle_count

    for py in 1:pny
        for px in 1:pnx
            i = isodd(px + py) ? 1 : 2
            x_rng = (1 + (px - 1) * pw):(px * pw)
            y_rng = (1 + (py - 1) * ph):(py * ph)
            @views ic[i][y_rng, x_rng] .= [c1, c2][i]
        end
    end

    return ic
end