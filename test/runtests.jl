using MFront
using Test

lpath = abspath(joinpath(dirname(Base.find_package("MFront")),"..","deps","usr","lib"))
libs = readdir(lpath)
println(abspath(joinpath(dirname(Base.find_package("MFront")),"..")))
println(abspath(joinpath(dirname(Base.find_package("MFront")),"..","deps")))
println(abspath(joinpath(dirname(Base.find_package("MFront")),"..","deps","usr")))
println(libs)

@testset "MFront.jl" begin
    # Write your own tests here.
    @test isfile(joinpath(lpath,"mgis-julia.so"))
    @test isfile(joinpath(lpath,"libMFrontGenericInterface.so"))
end
