module MFrontInterface
const lpath = abspath(joinpath(dirname(Base.find_package("MFrontInterface")),"..","deps","usr","lib"))

function mfront(model)
    insdir = abspath(joinpath(dirname(Base.find_package("MFrontInterface")),"..","deps","usr"))
    bindir = joinpath(insdir,"bin")
    curdir = pwd()
    tmpdir = mktempdir()

    cp(model,joinpath(tmpdir,model))
    cd(tempdir)
    open("run_mfront.sh","w") do fil
        write(fil,"export TFELHOME=$insdir\n")
        write(fil,"export MGISHOME=$insdir\n")
        write(fil,"export PATH=$bindir\n")
        write(fil,"export LD_LIBRARY_PATH=$MGISHOME/lib:$LD_LIBRARY_PATH\n")
        write(fil,"export LD_LIBRARY_PATH=$MGISHOME/lib/julia/mgis:$LD_LIBRARY_PATH\n")
        write(fil,"export LD_LIBRARY_PATH=$MGISHOME/lib/include:$LD_LIBRARY_PATH\n")
        write(fil, "mfront --obuild --install-path=$tmpdir --interface=generic $model\n")
    end

    chmod("run_mfront.sh",0o777)
    run(`./run_mfront.sh`)

    cp("libBehaviour.so",joinpath(curdir,"libBehaviour.so"))
    cd(curdir)
end


using CxxWrap
@wrapmodule(joinpath(lpath,"mgis-julia.so"),:define_mgis_module)
function __init__()
    @initcxx
end

module behaviour
const lpath = abspath(joinpath(dirname(Base.find_package("MFrontInterface")),"..","deps","usr","lib"))
using CxxWrap
@wrapmodule(joinpath(lpath,"mgis-julia.so"),:define_mgis_behaviour_module)
function __init__()
    @initcxx
end
end # module behaviour
end # module MFront`
