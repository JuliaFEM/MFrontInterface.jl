using MFront
using Test

lpath = abspath(joinpath(dirname(Base.find_package("MFront")),"..","deps","usr"))

@testset "MFront.jl" begin
    @testset "Binary dependencies"
        @test isfile(joinpath(lpath,"lib","mgis-julia.so"))
        @test isfile(joinpath(lpath,"lib","libMFrontGenericInterface.so"))
        @test isfile(joinpath(lpath,"bin","mfront"))
    end
end
