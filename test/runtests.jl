using MFrontInterface
using DelimitedFiles
using Test

@testset "MFrontInterface.jl" begin
    include("test_binary_dependencies.jl")
    if Sys.islinux()
        include("test_norton_model.jl")
    end
end
