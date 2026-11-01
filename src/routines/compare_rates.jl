"""
    compare_rates(
        wid::Int,
        len::Int,
        path_gps_rates::String,
        path_insar_rates::String,
        path_insar_los::String,
        path_insar_rsc::String
    )

Compare InSAR and GPS co-located linear deformation rates.

# Positional Arguments
- `wid`: `Int` width of InSAR deformation map (in pixels)
- `len`: `Int` length of InSAR deformation map (in pixels)
- `path_gps_rates`: `String` path to file containing GPS ENU rates [mm/year]
- `path_insar_rates`: `String` path to InSAR deformation map [cm/year]
- `path_insar_los`: `String` path to InSAR line-of-sight vector at each pixel
- `path_insar_rsc`: `String` path to InSAR geographic information

# Returns
- `stations_gps_vs_insar.csv`: comparison of InSAR and GPS deformation rates at 
each station.

# Notes
The InSAR deformation rate and LOS vector maps need to be formatted as `Float32`
binary files of concatenated matrices as:
- Rate file (2 bands): [amplitude'; deformation_rate']
- LOS file (3 bands): [East'; North'; Up']
"""
function compare_rates(
    wid::Int,
    len::Int,
    path_gps_rates::String,
    path_insar_rates::String,
    path_insar_los::String,
    path_insar_rsc::String
)
    # Read GPS data
    @assert isfile(path_gps_rates) "$path_gps_rates is not a valid path"
    stations = StationVel[]
    open(path_gps_rates, "r") do io
        readline(io)        # skip header
        for line in eachline(io)
            fields = split(strip(line), ",")
            push!(stations, StationVel(
                fields[1],
                parse(Float64, fields[2]),
                parse(Float64, fields[3]),
                parse(Float64, fields[4]),
                parse(Float64, fields[5]),
                parse(Float64, fields[6]),
                parse(Float64, fields[7]),
                parse(Float64, fields[8]),
                parse(Float64, fields[9])
            ))
        end
    end

    # Read the InSAR LOS deformation rate
    amp, vlos = read_unw_igram(path_insar_rates, wid, len)
    isvalid = amp .> 0

    # Read the InSAR LOS vector at each pixel
    los_e, los_n, los_u = read_los_grid(path_insar_los, wid, len)

    # Read the geographic information
    rsc = read_rsc(path_insar_rsc)
    println("len = $(len), wid = $(wid)")
    println("RSC length = $(rsc.length), RSC width = $(rsc.width)")
    @assert rsc.width == wid
    @assert rsc.length == len
    @assert (rsc.projection == "LL") "InSAR data must be on (latitude, longitude) grid"

    # Fetch InSAR LOS rate at each GPS station
    path_dir = dirname(path_gps_rates)
    path_out = joinpath(path_dir, "stations_gps_vs_insar.csv")
    path_log = joinpath(path_dir, "stations_gps_vs_insar.log")
    errs_los = Float64[]
    errs_vlm = Float64[]
    vlms_sar = Float64[]
    vlms_gps = Float64[]
    vloss_sar = Float64[]
    vloss_gps = Float64[]
    open(path_out, "w") do io
        open(path_log, "w") do log
            println(io, "station_id, latitude, longitude, height, t_start, t_end, gps_ve, gps_vn, gps_vu, gps_vlos, insar_vlos, insar_vu, err_vlos, err_vu")
            cnt = 0
            for gps in stations
                logprint(log, "\n------ Station $(gps.site) ------")
                row = round(Int, (gps.lat - rsc.y_first) / rsc.y_step + 1)
                col = round(Int, (gps.lon - rsc.x_first) / rsc.x_step + 1)
                if (1 <= row <= len) && (1 <= col <= wid)
                    if isvalid[row, col]
                        cnt += 1
                        logprint(log, "Station $(gps.site) is valid")
                        # project GPS onto line of sight
                        los_vec = Float64.([los_e[row, col], los_n[row, col], los_u[row, col]])
                        gps_vec = [gps.vel_e, gps.vel_n, gps.vel_u]
                        vlos_gps = dot(gps_vec, los_vec)
                        vlos_insar = vlos[row, col] * 10     # convert to mm
                        vlos_err = vlos_insar - vlos_gps

                        # Project InSAR onto vertical
                        vlm_insar = vlos_insar / los_vec[3]
                        vlm_err = vlm_insar - gps.vel_u

                        # Write to CSV file
                        println(io, "$(gps.site), $(gps.lat), $(gps.lon), $(gps.hgt), $(gps.t1), $(gps.t2), $(gps.vel_e), $(gps.vel_n), $(gps.vel_u), $(vlos_gps), $(vlos_insar), $(vlm_insar), $(vlos_err), $(vlm_err)")

                        # Print to REPL
                        logprint(log, "LOS vector: [$(los_vec[1]), $(los_vec[2]), $(los_vec[3])]")
                        logprint(log, "GPS LOS rate [mm/yr]: $(vlos_gps)")
                        logprint(log, "InSAR LOS rate [mm/yr]: $(vlos_insar)")
                        logprint(log, "LOS rate difference [mm/yr]: $(vlos_err)")
                        logprint(log, "GPS VLM [mm/yr]: $(gps.vel_u)")
                        logprint(log, "InSAR VLM [mm/yr]: $(vlm_insar)")
                        logprint(log, "VLM difference [mm/yr]: $(vlm_err)")

                        # Save
                        push!(errs_los, vlos_err)
                        push!(errs_vlm, vlm_err)
                        push!(vlms_sar, vlm_insar)
                        push!(vlms_gps, gps.vel_u)
                        push!(vloss_sar, vlos_insar)
                        push!(vloss_gps, vlos_gps)
                    else
                        logprint(log, "Station $(gps.site) is NOT at a valid InSAR pixel")
                    end
                else
                    logprint(log, "Station $(gps.site) is out of frame")
                end
            end
            # Statistics
            min_los0, max_los0 = extrema(abs.(errs_los))
            min_vlm0, max_vlm0 = extrema(abs.(errs_vlm))
            qlos = quantile(abs.(errs_los), [0.25, 0.5, 0.75])
            qvlm = quantile(abs.(errs_vlm), [0.25, 0.5, 0.75])
            rmse_los = sqrt.(mean(errs_los .^ 2))
            rmse_vlm = sqrt.(mean(errs_vlm .^ 2))
            med_los_err = median(vloss_sar - vloss_gps)
            med_vlm_err = median(vlms_sar - vlms_gps)
            qlos_new = quantile(abs.(errs_los .- med_los_err), [0.25, 0.5, 0.75])
            qvlm_new = quantile(abs.(errs_vlm .- med_vlm_err), [0.25, 0.5, 0.75])
            min_los1, max_los1 = extrema(abs.(errs_los .- med_los_err))
            min_vlm1, max_vlm1 = extrema(abs.(errs_vlm .- med_vlm_err))
            rmse_los_new = sqrt.(mean((errs_los .- med_los_err) .^ 2))
            rmse_vlm_new = sqrt.(mean((errs_vlm .- med_vlm_err) .^ 2))

            # Summary
            logprint(log, "\n----- Summary -----\n$(cnt) of $(length(stations)) stations are valid ")
            logprint(log, "- RMSE [mm/yr]:\nLOS: $(rmse_los)\nVLM$(rmse_vlm)")
            logprint(log, "- LOS absolute misfits [mm/yr]:\nmin = $(min_los0)\nQ1 = $(qlos[1])\nQ2 = $(qlos[2])\nQ3 = $(qlos[3])\nmax = $(max_los0)")
            logprint(log, "- VLM absolute misfits [mm/yr]:\nmin = $(min_vlm0)\nQ1 = $(qvlm[1])\nQ2 = $(qvlm[2])\nQ3 = $(qvlm[3])\nmax = $(max_vlm0)")
            logprint(log, "- Median misfit [mm/yr]:\nLOS = $(med_los_err)\nVLM = $(med_vlm_err)")
            logprint(log, "- Post-calibration RMSE [mm/yr]:\nLOS: $(rmse_los_new)\nVLM$(rmse_vlm_new)")
            logprint(log, "- Post calibration LOS absolute misfits [mm/year]:\nmin = $(min_los1)\nQ1 = $(qlos_new[1])\nQ2 = $(qlos_new[2])\nQ3 = $(qlos_new[3])\nmax = $(max_los1)")
            logprint(log, "- Post calibration VLM absolute misfits [mm/year]:\nmin = $(min_vlm1)\nQ1 = $(qvlm_new[1])\nQ2 = $(qvlm_new[2])\nQ3 = $(qvlm_new[3])\nmax = $(max_vlm1)")
        end
    end
    println("Wrote to $path_out")
    return vloss_gps, vloss_sar, vlms_gps, vlms_sar
end

function dot(
    vec1::Vector{Float64},
    vec2::Vector{Float64}
)
    n = length(vec1)
    runsum = zero(Float64)
    for k in 1:n
        val1 = vec1[k]
        val2 = vec2[k]
        runsum += val1 * val2
    end
    return runsum
end

function logprint(
    log::IO,
    msg::AbstractString
)
    println(msg)
    println(log, msg)
end
