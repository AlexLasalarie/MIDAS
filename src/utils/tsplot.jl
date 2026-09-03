function tsplot(
    path_tenv::String,
    path_vel::String,
    path_out::String,
    frame::String;
    fit::Symbol=:linear,
)
    # Parse data
    tenv = read_tenv(path_tenv)
    vel = read_vel(path_vel)
    npts = length(tenv)
    t = Vector{Float64}(undef, npts)
    enu = Matrix{Float64}(undef, npts, 3)
    for (k, pt) in enumerate(tenv)
        t[k] = pt.decy
        enu[k, 1] = (pt.e - vel.off_e) * 1000           # mm
        enu[k, 2] = (pt.n - vel.off_n) * 1000           # mm
        enu[k, 3] = (pt.u - vel.off_u) * 1000           # mm
    end
    vels = [vel.e, vel.n, vel.u] .* 1000                # mm/year
    errs = [vel.sig_e, vel.sig_n, vel.sig_u] .* 1000    # mm/year

    # Plotting
    cm_to_px(cm) = round(Int, cm / 2.54 * 100)
    ylabels = ["East [mm]", "North [mm]", "Up [mm]"]
    plots_list = []
    for i in 1:3

        # Base scatter plot for the panel
        y = view(enu, :, i)
        p_i = scatter(
            t, y,
            markersize=2.5,
            label=false,
            ylabel=ylabels[i],
            grid=false,
            framestyle=:box,
        )

        # Conditionally add the linear fit line if requested
        if fit === :linear
            xfit = t .- t[1]
            yfit = vels[i] .* xfit
            rate_str = "$(round(vels[i], digits=3)) ± $(round(errs[i], digits=3)) mm/yr"
            plot!(p_i, t, yfit, linewidth=1.5, label=rate_str, color=:red)
        end

        # Restrict xlabel to the bottom panel only
        if i == 3
            xlabel!(p_i, "Time")
        end
        push!(plots_list, p_i)
    end

    # Combine individual panels into a 3x1 layout
    p = plot(
        plots_list...,
        layout=(3, 1),
        size=(cm_to_px(15.0), cm_to_px(18.0)),
        link=:x,
        plot_title="Station: $(tenv[1].id), Frame: $frame"
    )
    savefig(p, path_out)
    return p
end
