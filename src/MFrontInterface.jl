module MFrontInterface
const lpath = abspath(joinpath(dirname(Base.find_package("MFrontInterface")),"..","deps","usr","lib"))

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
