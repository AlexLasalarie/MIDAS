"""
    convert2tenv(
        t1::String,
        t2::String;
        path_dir::String="."
    )

Convert `tenv3` files into `tenv` files and imposes a time window.

# Positional Arguments
- `t1`: `String` start time formatted as `"yyyyMMdd"`
- `t2`: `String` end time formatted as `"yyyyMMdd"`

# Optional Arguments
- `path_dir`: `String` path to directory containing the `.tenv3` data.

# Returns
GPS time series in `.tenv` format, trimmed to the specified time window.
"""
function convert2tenv(
    t1::String,
    t2::String;
    path_dir::String="."
)
    ext = ".tenv3"
    decy_start = datestr2decy(t1, "yyyymmdd")
    decy_end = datestr2decy(t2, "yyyymmdd")
    list_tenv3 = filter(file -> endswith(file, ext), readdir(path_dir, join=true))
    for path_tenv3 in list_tenv3
        gps = read_tenv3(path_tenv3)
        valid_points = Vector{TenvPoint}()
        for pt in gps
            if (pt.decy > decy_start) & (pt.decy < decy_end)
                push!(valid_points, pt)
            end
        end
        if !isempty(valid_points)
            path_tenv = replace(path_tenv3, ".tenv3" => ".tenv")
            write_tenv(path_tenv, valid_points)
            println("Wrote to: $path_tenv")
        end
    end
end
