using MFrontInterface
using DelimitedFiles
using Suppressor
using Test
lpath = MFrontInterface.lpath

# shorten namespace name
mbv = MFrontInterface.behaviour

# comparison criterion
eps = 1.e-12

@testset "MFrontInterface.jl" begin
    include("test_binary_dependencies.jl")
    if Sys.islinux()
        @testset "Norton model" begin include("test_norton_model.jl") end
        include("test_show_methods.jl")
    end
end
