@testset "Binary dependencies" begin
    if Sys.iswindows()
        lpath = abspath(joinpath(dirname(Base.find_package("MFrontInterface")),"..","deps","usr","bin"))
        @test isfile(joinpath(lpath,"mgis-julia.dll"))
        @test isfile(joinpath(lpath,"libMFrontGenericInterface.dll"))
        @test isfile(joinpath(lpath,"mfront.exe"))
    else
        lpath = abspath(joinpath(dirname(Base.find_package("MFrontInterface")),"..","deps","usr"))
        @test isfile(joinpath(lpath,"lib","mgis-julia.so"))
        @test isfile(joinpath(lpath,"lib","libMFrontGenericInterface.so"))
        @test isfile(joinpath(lpath,"bin","mfront"))
    end
end
