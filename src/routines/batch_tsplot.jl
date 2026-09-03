"""
    batch_tsplot(
        frame::String;
        fit::Symbol=:linear,
        path_dir::String="."
    )

Plot the time series and fits for all stations.

# Positional Arguments
- `frame`: `String` reference frame (e.g. "NA")

# Optional Arguments
- `fit`: `Symbol` type of fit to plot (default is `:linear`)
- `path_dir`: `String` path to directory containing the `tenv` and `vel` data

# Returns
- `figs` directory containing the plots of the GPS time series for each station
"""
function batch_tsplot(
    frame::String;
    fit::Symbol=:linear,
    path_dir::String="."
)
    list_tenv = filter(endswith(".tenv"), readdir(path_dir, join=true))
    output_dir = joinpath(path_dir, "figs")
    if !isdir(output_dir)
        mkdir(output_dir)
    end
    for path_tenv in list_tenv
        path_vel = replace(path_tenv, ".tenv" => ".vel")
        file_base = splitext(basename(path_tenv))[1]
        path_out = joinpath(output_dir, "$file_base.pdf")
        if isfile(path_vel)
            tsplot(path_tenv, path_vel, path_out, frame, fit=fit)
        end
    end
end
