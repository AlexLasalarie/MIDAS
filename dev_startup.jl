# Activate the current project environment
using Pkg
Pkg.activate(".")
if !isfile("Manifest.toml")
    @info "No Manifest found, instantiating..."
    Pkg.instantiate()
end

# ----- Load non-base pkgs (must be in dev. global path)

# Load Revise (auto diff)
try
    using Revise
    println("Revise loaded")
catch e
    @warn "Revise not found. Consider adding to your base environment."
end

# Load BenchmarkTools (test performance)
try
    using BenchmarkTools
    println("BenchmarkTools loaded")
catch e
    @warn "BenchmarkTools not found. Consider adding to your base environment."
end

# Load Infiltrator (breakpoints)
try
    using Infiltrator
    println("Infiltrator loaded")
catch e
    @warn "Infiltrator not found. Consider adding to your base environment."
end

# ----- Load the package
using MIDAS
