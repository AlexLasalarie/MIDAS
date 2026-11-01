"""
    read_rsc(filepath::String)

Read the geographic information contained in `filepath`.

# Arguments
- `filepath`: `String` path to `.rsc` file

# Returns
- `rsc`: `Rsc` object containing the geographic information
"""
function read_rsc(
    filepath::String
)
    @assert isfile(filepath) "Could not find the rsc file: $filepath"

    # Read key-value pairs
    params = open(filepath, "r") do io
        result = Dict{String,String}()
        for line in eachline(io)
            parts = split(line)
            length(parts) >= 2 || continue
            result[parts[1]] = parts[2]
        end
        result
    end

    # Create Rsc object
    return Rsc(
        parse(Int64, params["WIDTH"]),
        parse(Int64, params["FILE_LENGTH"]),
        parse(Float64, params["X_FIRST"]),
        parse(Float64, params["Y_FIRST"]),
        parse(Float64, params["X_STEP"]),
        parse(Float64, params["Y_STEP"]),
        params["X_UNIT"],
        params["Y_UNIT"],
        parse(Int64, params["Z_OFFSET"]),
        parse(Int64, params["Z_SCALE"]),
        params["PROJECTION"]
    )
end
