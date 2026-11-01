"""
Read the line-of-sight (LOS) for an InSAR frame. The file should be formatted as
a `Float32` binary containing the `ENU` components as 3 concatenated bands in 
`row-major` format: `[E'; N'; U']`

This is similar to the `unwrapped interferogram` format (`[amp'; psi']`) but 
with 3 layers instead of 2.
"""
function read_los_grid(
    filepath::String,
    wid::Int,
    len::Int
)
    @assert isfile(filepath) "$filepath is not a valid path"
    buffer = Array{Float32}(undef, 3 * wid, len)
    open(filepath) do io
        read!(io, buffer)
    end
    viewe = view(buffer, 1:wid, :)
    viewn = view(buffer, wid+1:2*wid, :)
    viewu = view(buffer, 2*wid+1:3*wid, :)
    e = permutedims(viewe)
    n = permutedims(viewn)
    u = permutedims(viewu)
    return e, n, u
end
