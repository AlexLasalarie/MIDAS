"""
    function batch_midas(
        midas_bin::String,
        path_dir::String=".",
    )

Run the MIDAS algorithm to derive surface deformation rates.

# Positional Arguments
- `midas_bin`: `String` path to MIDAS binary

# Optional Arguments
- `path_dir`: `String` path to directory containing the `.tenv` and `.step` files

# Returns
- `.vel` files containing the information on linear rates
- `.renv` files containing the detrended time series in a `tenv` format
"""
function batch_midas(
    midas_bin::String;
    path_dir::String=".",
)
    ext = ".tenv"
    list_tenv = filter(endswith(ext), readdir(path_dir; join=true))
    for path_tenv in list_tenv
        println("Processing: $(path_tenv)")
        path_step = replace(path_tenv, ".tenv" => ".step")
        try
            run(`$midas_bin -s $path_step $path_tenv`)
        catch e
            @warn "MIDAS failed for $path_tenv: ($e)"
        end
    end
end
