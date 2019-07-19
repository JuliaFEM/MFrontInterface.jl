module MFrontInterface
import Libdl
if Sys.iswindows()
    const lpath = abspath(joinpath(dirname(Base.find_package("MFrontInterface")),"..","deps","usr","bin"))
else
    const lpath = abspath(joinpath(dirname(Base.find_package("MFrontInterface")),"..","deps","usr","lib"))
end

using CxxWrap
@wrapmodule(joinpath(lpath,"mgis-julia." * Libdl.dlext),:define_mgis_module)
function __init__()
    @initcxx
end

module behaviour
if Sys.iswindows()
    const lpath = abspath(joinpath(dirname(Base.find_package("MFrontInterface")),"..","deps","usr","bin"))
else
    const lpath = abspath(joinpath(dirname(Base.find_package("MFrontInterface")),"..","deps","usr","lib"))
end
using CxxWrap
import Libdl
@wrapmodule(joinpath(lpath,"mgis-julia." * Libdl.dlext),:define_mgis_behaviour_module)
function __init__()
    @initcxx
end
end # module behaviour
end # module MFront`
