using MFront
using Test

lpath = abspath(joinpath(dirname(Base.find_package("MFront")),"..","deps","usr","lib"))

@testset "MFront.jl" begin
    # Write your own tests here.
    @test isfile(joinpath(lpath,"mgis-julia.so"))
    @test isfile(joinpath(lpath,"libMFrontGenericInterface.so"))
end
