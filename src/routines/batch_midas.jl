"""
    function batch_midas(
        midas_bin::String;
        path_dir::String=".",
        path_llh::String="stations_llh.csv"
    )

Run the MIDAS algorithm to derive surface deformation rates.

# Positional Arguments
- `midas_bin`: `String` path to MIDAS binary

# Optional Arguments
- `path_dir`: `String` path to directory containing the `.tenv` and `.step` files
- `path_llh`: `String` path to file containing the (lat, lon, hgt) information 
    for all stations

# Returns
- `.vel` files containing the information on linear rates
- `.renv` files containing the detrended time series in a `tenv` format
"""
function batch_midas(
    midas_bin::String;
    path_dir::String=".",
    path_llh::String="stations_llh.csv"
)
    # Run MIDAS
    list_tenv = filter(endswith(".tenv"), readdir(path_dir; join=true))
    for path_tenv in list_tenv
        println("Processing: $(path_tenv)")
        path_step = replace(path_tenv, ".tenv" => ".step")
        try
            run(`$midas_bin -s $path_step $path_tenv`)
        catch e
            @warn "MIDAS failed for $path_tenv: ($e)"
        end
    end

    # Read the llh information for all inbound stations
    sites = Vector{String}()
    gps = Vector{StationLLH}()
    open(path_llh, "r") do io
        readline(io)                            # skip the header
        for line in eachline(io)
            tokens = split(line, ", ")
            push!(gps, StationLLH(
                tokens[1],
                parse(Float64, tokens[2]),
                parse(Float64, tokens[3]),
                parse(Float64, tokens[4])
            ))
            push!(sites, tokens[1])
        end
    end

    # Reads the solution and outputs to summary file
    path_out = joinpath(path_dir, "stations_vlm.csv")
    open(path_out, "w") do io
        list_vel = filter(endswith(".vel"), readdir(path_dir; join=true))
        println(io, "station_id, latitude, longitude, height, vlm_mm_per_yr")
        for path_vel in list_vel
            vel = read_vel(path_vel)
            idx = findfirst(==(vel.site), sites)
            vlm = round(vel.u * 1000, digits=6)     # convert to mm/yr
            println(io, "$(gps[idx].id), $(gps[idx].lat), $(gps[idx].lon), $(gps[idx].hgt), $(vlm)")
        end
    end
end
