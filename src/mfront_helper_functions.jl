
pkg_dir = dirname(Base.find_package("MFrontInterface"))
lib_dir = joinpath(pkg_dir,"..","deps","usr","lib")
home_dir = joinpath(pkg_dir,"..","deps","usr")
bin_dir = joinpath(pkg_dir,"..","deps","usr","bin")
cur_path = ENV["PATH"]


function mfront_sh_script(mfront_fn; install_dir=pwd())
    script = """
    #!/bin/sh
    export TFELHOME=$home_dir
    export MGISHOME=$home_dir
    export LD_LIBRARY_PATH=$lib_dir
    export PATH=$bin_dir:$cur_path
    mfront --install-path=$install_dir --obuild --interface=generic $mfront_fn
    cd src
    patchelf --set-rpath $lib_dir libBehaviour.so
    """
    return script
end

"""
This is shell helper function to run mfront-command
Note: you will need to make sure following dependencies are installed and in your
`PATH`: cmake, gcc, g++, patchelf
"""
function mfront(;mfront_model_string,overwrite=false, libname="libBehaviour.so",install_dir=pwd())
    cur_dir = pwd()
    tmpfolder = tempname()
    mkdir(tmpfolder)
    cd("tmpfolder")
    open("model.mfront","w") do fil
        write(fil,mfront_model_string)
    end
    open("build.sh","w") do fil
        write(fil,mfront_sh_script("model.mfront"; install_dir=tmpfolder))
    end
    chmod("build.sh",0o777)
    cmdout = run(`build.sh`)
    if cmdout.exitcode != 0
        println("mfront build command errored:")
        println(cmdout.err)
    end

    libfil = joinpath(tmpfolder,"src","libBehaviour.so")
    destfil = joinpath(install_dir,libname)
    if overwrite
        mv(libfil,destfil, force=overwrite)
    else
        for i=1:10000
            try
                mv(libfil,destfil, force=overwrite)
                break
            catch
                oldname = splitext(destname)
                destfil = oldname[1] * string(i) * oldname[2]
            end
        end
    end


end
