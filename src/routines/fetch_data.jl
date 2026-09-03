"""
    fetch_data(
        min_lat::Real,
        max_lat::Real,
        min_lon::Real,
        max_lon::Real;
        frame::String="NA",
        path_dir::String=".",
        path_llh::String="",
        path_step::String=""
    )

Fetches the GPS data for all stations contained within the specified latitude,
longitude box.

# Positional Arguments
- `min_lat`: `Real` minimum latitude (in decimal degree)
- `max_lat`: `Real` maximum latitude (in decimal degree)
- `min_lon`: `Real` minimum longitude (in decimal degree)
- `max_lon`: `Real` maximum longitude (in decimal degree)

# Optional Arguments
- `frame`: `String` reference frame, default is `North American Plate ("NA")`
- `path_dir`: `String` path to directory to download data to (default is `"."`)
- `path_llh`: `String` path to file containing the `(lat, lon, hgt)` of all stations
- `path_step`:`String` path to file containing all known steps

# Returns
1. `XXXX.tenv3` time series at stations within the box in `tenv3` format
2. `XXXX.step` known steps for a station within the box
3. `stations_inbox.csv` (lat, lon, height) of stations within the box
4. `stations_llh.txt` (lat, lon, height) of ALL stations (not just the ones in box)
5. `stations_steps.txt` known steps for all stations (not just the ones in box)
"""
function fetch_data(
    min_lat::Real,
    max_lat::Real,
    min_lon::Real,
    max_lon::Real;
    frame::String="NA",
    path_dir::String=".",
    path_llh::String="",
    path_step::String=""
)
    # Download the llh file if missing
    if path_llh == ""
        url = "https://geodesy.unr.edu/gps_timeseries/IGS20/llh/llh.out"
        response = HTTP.get(url)
        data_string = String(response.body)
        lines = split(data_string, " \n")
        path_llh = joinpath(path_dir, "stations_llh.txt")
        open(path_llh, "w") do io
            for line in lines
                if line != ""
                    println(io, line)
                end
            end
        end
    end

    # Download the step file if missing
    if path_step == ""
        url = "https://geodesy.unr.edu/NGLStationPages/steps.txt"
        response = HTTP.get(url)
        data_string = String(response.body)
        lines = split(data_string, "\n")
        path_step = joinpath(path_dir, "stations_steps.txt")
        open(path_step, "w") do io
            for line in lines
                if line != ""
                    println(io, line)
                end
            end
        end
    end

    # Read the llh file and select stations
    stations_llh = Vector{StationLLH}()
    open(path_llh, "r") do io
        for line in eachline(io)
            if line != ""
                tokens = split(line)
                site = tokens[1]
                lat = parse(Float64, tokens[2])
                lon = parse(Float64, tokens[3])
                lon = mod(lon + 180, 360) - 180
                hgt = parse(Float64, tokens[4])
                if (lat > min_lat) & (lat < max_lat) & (lon > min_lon) & (lon < max_lon)
                    push!(stations_llh, StationLLH(site, lat, lon, hgt))
                end
            end
        end
    end

    # Write out to file
    path_out = joinpath(path_dir, "stations_inbox.csv")
    open(path_out, "w") do io
        hdr = "site, latitude, longitude, height"
        println(io, hdr)
        for gps in stations_llh
            line = "$(gps.id), $(gps.lat), $(gps.lon), $(gps.hgt)"
            println(io, line)
        end
    end

    # Read the master step file
    steps = Vector{Step}()
    open(path_step, "r") do io
        for line in eachline(io)
            if line != ""
                tokens = split(line)
                site = String(tokens[1])
                date = String(tokens[2])
                type = parse(Int, tokens[3])
                push!(steps, Step(site, date, type))
            end
        end
    end

    # Create the individual step files
    for gps in stations_llh
        path_out = joinpath(path_dir, "$(gps.id).step")
        open(path_out, "w") do io
            for step in steps
                if step.site == gps.id
                    decy = round(step.decy, digits=4)
                    println(io, "$(step.site)  $(decy)  $(step.date)  $(step.type)")
                end
            end
        end
    end

    # Download the data
    for gps in stations_llh
        url = "https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/$frame/$(gps.id).$frame.tenv3"
        try
            response = HTTP.get(url; status_exception=false)
            if response.status == 200
                data_string = String(response.body)
                println("Successfully downloaded: $(gps.id)")
            else
                @warn "Station $(gps.id) returned status $(response.status)"
            end
            # Brief pause to be polite to the server and avoid connection drops
            sleep(0.05)
        catch e
            @warn "Failed to download $(gps.id): $e"
        end
        lines = split(data_string, "\n")
        path_out = joinpath(path_dir, "$(gps.id).tenv3")
        open(path_out, "w") do io
            for line in lines
                if line != ""
                    println(io, line)
                end
            end
        end
    end
end
