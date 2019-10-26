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
export get_initial_state, get_parameters, get_external_state_variables

function Base.show(io::IO,m::BehaviourAllocated)
    print(io, "behaviour ", get_behaviour(m))
    print(io, " in shared library ", get_library(m))
    print(io, " for modelling hypothesis ")
    print(io, toString(get_hypothesis(m)))
    print(io, " generated from ", get_source(m), " using TFEL version: ")
    print(io, get_tfel_version(m), ".")
end

function Base.iterate(iter::RealsVectorRef, state=(1, 1))
    element, count = state
    if count > length(iter)
        return nothing
    end
    return (iter[element], (element + 1, count + 1))
end

function Base.show(io::IO, m::RealsVectorRef)
    println(io, length(m),"-element RealsVector")
    for i in m
        println(io, " ", i)
    end
end

function Base.iterate(iter::StringsVectorAllocated, state=(1, 1))
    element, count = state
    if count > length(iter)
        return nothing
    end
    return (iter[element], (element + 1, count + 1))
end

function Base.show(io::IO, m::StringsVectorAllocated)
    println(io, length(m),"-element StringsVector")
    for i in m
        println(io, " ", i)
    end
end

function Base.iterate(iter::VariablesVectorAllocated, state=(1, 1))
    element, count = state
    if count > length(iter)
        return nothing
    end
    return (iter[element], (element + 1, count + 1))
end

function Base.show(io::IO, m::VariablesVectorAllocated)
    println(io, length(m),"-element VariablesVector")
    for i in m
        println(io, " ", get_name(i))
    end
end


end # module behaviour
# Re-exporting behaviour model functions
using .behaviour
export load, BehaviourData, get_variable_offset, get_internal_state_variables
export get_hypothesis, set_time_increment!, set_external_state_variable!
export get_final_state, update, get_gradients, get_initial_state, integrate
export get_initial_state, get_parameters, get_external_state_variables

include("mfront_material.jl")
export MFrontMaterial, MFrontDriverState, MFrontVariableState, MFrontExternalVariableState
export integrate_material!, update_material!, reset_material!
export material_preprocess_analysis!, material_preprocess_increment!, MFrontMaterialModel

include("mfront_helper_functions.jl")
export mfront

end # module MFront`
