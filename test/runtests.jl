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

        @testset "show methods" begin include("test_show_methods.jl") end

        @testset "test MFront ideal plastic material model" begin
        include("test_isotropic_linear_hardening_plasticity.jl")
        end

        @testset "test MFront ideal plastic material model with shear strain" begin
        include("test_isotropic_linear_hardening_plasticity_shear.jl")
        end

        @testset "test MFront together with FEMMaterials" begin
        include("test_mfront_mecamatso.jl")
        end

        @testset "test MFront together with JuAFEM" begin
        include("test_mfront_juafem_3dbeam.jl")

        @testset "test plasticity with uniaxial_increment!" begin
        include("test_vonmises_uniaxial.jl")
        end
        end
    end
end
