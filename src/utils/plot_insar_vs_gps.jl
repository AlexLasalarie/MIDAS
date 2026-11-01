function plot_insar_vs_gps(
    gps::Vector{Float64},
    sar::Vector{Float64},
    x_label::String,
    y_label::String,
    filepath::String,
    xbnds::Vector{Float64},
    ybnds::Vector{Float64},
    class_edges::Vector{Float64},
    colors::Vector{Symbol};
    figsize::Tuple{Float64,Float64}=(9.0, 9.0),
    fontsize::Int=8,
)
    @assert length(colors) == length(class_edges) + 1 "You need one more color than the number of thresholds"
    misfits = abs.(sar .- gps)
    rmse = sqrt(mean((sar .- gps) .^ 2))
    cvec = Vector{Symbol}(undef, length(misfits))
    for (k, misfit) in enumerate(misfits)
        idx = searchsortedfirst(class_edges, misfit)
        cvec[k] = colors[idx]
    end
    bnd1, bnd2 = extrema([xbnds, ybnds])
    figsize_px = round.(Int, collect(figsize) .* 100 ./ 2.54)
    plt = plot(
        [bnd1, bnd2],
        [bnd1, bnd2],
        color=:black,
        label=false,
        size=figsize_px,
        guidefontsize=fontsize,
        tickfontsize=fontsize,
        titlefontsize=fontsize,
        legendfontsize=fontsize,
    )
    scatter!(
        plt,
        gps, sar,
        markersize=4,
        markerstrokewidth=0,
        color=cvec,
        label=false,
        grid=false,
        framestyle=:box,
        xlabel=x_label,
        ylabel=y_label,
        xlims=(xbnds[1], xbnds[2]),
        ylims=(ybnds[1], ybnds[2]),
        aspect_ratio=:equal,
    )
    annotate!(
        plt,
        xbnds[1] + 0.05 * (xbnds[2] - xbnds[1]),
        ybnds[2] - 0.05 * (ybnds[2] - ybnds[1]),
        text("RMSE = $(round(rmse, digits=2)) mm/year", fontsize, :left)
    )
    savefig(plt, filepath)
end
