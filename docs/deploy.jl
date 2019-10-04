# This file is a part of JuliaFEM.
# License is MIT: see https://github.com/JuliaFEM/MFrontInterface.jl/blob/master/LICENSE

using Documenter

deploydocs(
    repo = "github.com/JuliaFEM/MFrontInterface.jl.git",
    target = "build",
    deps = nothing,
    make = nothing)
