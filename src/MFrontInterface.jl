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
export load, BehaviourData, get_variable_offset, get_internal_state_variables
export get_hypothesis, set_time_increment!, set_external_state_variable!
export get_final_state, update, get_gradients, get_initial_state, integrate
export get_initial_state
end # module behaviour
# Re-exporting behaviour model functions
using .behaviour
export load, BehaviourData, get_variable_offset, get_internal_state_variables
export get_hypothesis, set_time_increment!, set_external_state_variable!
export get_final_state, update, get_gradients, get_initial_state, integrate
export get_initial_state
end # module MFront`
