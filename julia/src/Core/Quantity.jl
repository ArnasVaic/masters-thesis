function quantity(concentration::Matrix{Float64}, disc::Discretization)
    w, h = disc.size
    return w * h * sum(concentration) / length(concentration)
end

function reagent_quantity(concentrations::SolutionState, disc::Discretization)
    q_c1 = quantity(concentrations[1], disc)
    q_c2 = quantity(concentrations[2], disc)
    return q_c1 + q_c2
end