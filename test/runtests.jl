using MFront
using Test

@testset "MFront.jl" begin
    # Write your own tests here.
    @test isfile("../deps/usr/lib/mgis-julia.so")
    @test isfile("../deps/usr/lib/libMFrontGenericInterface.so")
end
