
# %%
using JLD2
using YagModel
using CairoMakie
using Printf

capture = load("capture.jld2")
capture = capture["capture"]

# %%

capture.length


# %%

function hours_to_hhmm(hours::Float64)
    h = floor(Int, hours)
    m = round(Int, (hours - h) * 60)
    
    if m == 60
        h += 1
        m = 0
    end
    
    @sprintf("%02dh %02dmin", h, m)
end

show_step = 700

minval, maxval = 0, maximum([
    maximum(capture.c1[1]), 
    maximum(capture.c2[2])]
)
fig = Figure(fontsize=18)

time = hours_to_hhmm(capture.t[show_step] / 3600)

ax = Axis(
    fig[1, 1], 
    title=L"Concentration of $c_3$ at step %$(show_step) (%$(time))", 
    xlabel="X", 
    ylabel="Y"
)

ct = capture.c3[show_step]

hm = heatmap!(
    ax,
    ct, 
    colormap = :viridis, 
    colorrange = (minval, maxval)
)

Colorbar(fig[:, end+1], hm, label="Concentration")

fig