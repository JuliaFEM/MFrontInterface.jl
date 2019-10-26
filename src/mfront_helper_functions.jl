
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

function move_lib(from,to,overwrite=false)
    orig_to = splitext(to)
    if overwrite
        mv(from,to, force=overwrite)
    else
        for i=1:10000
            try
                mv(from, to, force=overwrite)
                break
            catch
                to = orig_to[1] * string(i) * orig_to[2]
            end
        end
    end
end

"""
This is shell helper function to run mfront-command
Note: you will need to make sure following dependencies are installed and in your
`PATH`: cmake, gcc, g++, patchelf

Returns the path to the libBehaviour in tmp folder
"""
function mfront(mfront_model_string)
    cur_dir = pwd()
    tmpfolder = tempname()
    mkdir(tmpfolder)
    cd(tmpfolder)
    open("model.mfront","w") do fil
        write(fil,mfront_model_string)
    end
    open("build.sh","w") do fil
        write(fil,mfront_sh_script("model.mfront"; install_dir=tmpfolder))
    end
    chmod("build.sh",0o777)
    cmdout = run(`./build.sh`)
    if cmdout.exitcode != 0
        println("mfront build command errored:")
        println(cmdout.err)
    end
    cd(cur_dir)
    return joinpath(tmpfolder,"src","libBehaviour.so")
end
