module MIDAS

# ----- External dependencies
using HTTP
using Dates
using Printf
using Plots

# ----- Internal dependencies

# Types
include("types.jl")

# File I/O
include("fileio/datestr2decy.jl")
include("fileio/read_tenv3.jl")
include("fileio/read_tenv.jl")
include("fileio/read_vel.jl")
include("fileio/write_tenv.jl")

# Utilities
include("utils/tsplot.jl")

# Routines
include("routines/fetch_data.jl")
include("routines/convert2tenv.jl")
include("routines/batch_midas.jl")
include("routines/batch_tsplot.jl")

# ----- Exports
export fetch_data
export convert2tenv
export batch_midas
export batch_tsplot
export auto_midas

# ----- Orchestrator
"""
    function auto_midas(
        min_lat::Real,
        max_lat::Real,
        min_lon::Real,
        max_lon::Real,
        t1::String,
        t2::String,
        midas_bin::String;
        path_dir::String=".",
        frame::String="NA"
    )

Automated GPS processing pipeline. Data is downloaded from the UNR server and 
linear trends are derived using the MIDAS algorithm.

# Positional Arguments
- `min_lat`: `Real` minimum latitude (in decimal degree)
- `max_lat`: `Real` maximum latitude (in decimal degree)
- `min_lon`: `Real` minimum longitude (in decimal degree)
- `max_lon`: `Real` maximum longitude (in decimal degree)
- `t1`: `String` start time formatted as `"yyyyMMdd"`
- `t2`: `String` end time formatted as `"yyyyMMdd"`

# Optional Arguments
- `frame`: `String` reference frame, default is `North American Plate ("NA")`
- `path_dir`: `String` path to directory to download data to (default is `"."`)

# Returns
- `figs` directory containing `PDF` plots of the GPS time series
- `.tenv` files containing the GPS time series in `tenv` format
- `.vel` files containing the linear rates derived from MIDAS
- `.renv` files containing the detrended time series
"""
function auto_midas(
    min_lat::Real,
    max_lat::Real,
    min_lon::Real,
    max_lon::Real,
    t1::String,
    t2::String,
    midas_bin::String;
    path_dir::String=".",
    frame::String="NA"
)
    fetch_data(min_lat, max_lat, min_lon, max_lon, path_dir=path_dir, frame=frame)
    convert2tenv(t1, t2, path_dir=path_dir)
    batch_midas(midas_bin, path_dir)
    batch_tsplot(frame, path_dir=path_dir)
end

end
