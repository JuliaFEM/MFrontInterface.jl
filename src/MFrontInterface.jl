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
export load, BehaviourData, get_variable_offset, get_internal_state_variables
export get_hypothesis, set_time_increment!, set_external_state_variable!
export get_final_state, update, get_gradients, get_initial_state, integrate
export get_initial_state

function Base.show(io::IO,m::BehaviourAllocated)
    println(io, "libBehaviour: generated from ", get_source(m))
    println(io, "name of the behaviour: ", get_behaviour(m))
    print(io, "TFEL version: ", get_tfel_version(m))
end

# function Base.show(io::IO,m::BehaviourDataAllocated)
#     print(io, "Behaviour Data ")
# end

end # module behaviour
# Re-exporting behaviour model functions
using .behaviour
export load, BehaviourData, get_variable_offset, get_internal_state_variables
export get_hypothesis, set_time_increment!, set_external_state_variable!
export get_final_state, update, get_gradients, get_initial_state, integrate
export get_initial_state
end # module MFront`
