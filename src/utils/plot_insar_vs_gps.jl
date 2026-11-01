function plot_insar_vs_gps(
    gps::Vector{Float64},
    sar::Vector{Float64},
    x_label::String,
    y_label::String,
    filepath::String,
    xbnds::Vector{Float64},
    ybnds::Vector{Float64},
    class_edges::Vector{Float64},
    colors::Vector{Symbol}
)
    @assert length(colors) == length(class_edges) + 1 "You need one more color than the number of thresholds"
    misfits = abs.(sar .- gps)
    cvec = Vector{Symbol}(undef, length(misfits))
    for (k, misfit) in enumerate(misfits)
        idx = searchsortedfirst(class_edges, misfit)
        cvec[k] = colors[idx]
    end
    bnd1, bnd2 = extrema([xbnds, ybnds])
    plt = plot(
        [bnd1, bnd2],
        [bnd1, bnd2],
        color=:black,
        label=false
    )
    scatter!(
        plt,
        gps, sar,
        markersize=2.5,
        markerstrokewidth=0,
        color=cvec,
        label=false,
        grid=false,
        framestyle=:box,
        xlabel=x_label,
        ylabel=y_label,
        xlims=(xbnds[1], xbnds[2]),
        ylims=(ybnds[1], ybnds[2]),
        aspect_ratio=:equal
    )
    savefig(plt, filepath)
end
