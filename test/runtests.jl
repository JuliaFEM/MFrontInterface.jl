using MFrontInterface
using Test

lpath = abspath(joinpath(dirname(Base.find_package("MFrontInterface")),"..","deps","usr"))

@testset "MFrontInterface.jl" begin
    @testset "Binary dependencies" begin
        @test isfile(joinpath(lpath,"lib","mgis-julia.so"))
        @test isfile(joinpath(lpath,"lib","libMFrontGenericInterface.so"))
        @test isfile(joinpath(lpath,"bin","mfront"))
    end
end
