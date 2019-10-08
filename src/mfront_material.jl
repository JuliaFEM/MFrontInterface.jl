using Parameters
using Tensors
using Materials
using FEMMaterials

mgis_bv = MFrontInterface.behaviour

"""
Variables updated by MFront.
"""
@with_kw struct MFrontVariableState <: AbstractMaterialState
    stress :: SymmetricTensor{2,3} = zero(SymmetricTensor{2,3,Float64})
    jacobian :: SymmetricTensor{4,3} = zero(SymmetricTensor{4,3,Float64})
end

"""
Variables passed in for information.
These drive evolution of the material state.
"""
@with_kw mutable struct MFrontDriverState <: AbstractMaterialState
    time :: Float64 = zero(Float64)
    strain :: SymmetricTensor{2,3} = zero(SymmetricTensor{2,3,Float64})
end

"""
Material external variables in order that is specific to chosen MFront behaviour.
"""
@with_kw struct MFrontExternalVariableState <: AbstractMaterialState
    names :: Array{String,1} = [""]
    values :: Array{Float64,1} = zeros(Float64, 1)
end

"""
MFront material structure.

`lib_path` is the path to the compiled shared library.
`behaviour` is the loaded material behaviour from the shared library.
"""
@with_kw mutable struct MFrontMaterial <: AbstractMaterial
    drivers :: MFrontDriverState = MFrontDriverState()
    ddrivers :: MFrontDriverState = MFrontDriverState()
    variables :: MFrontVariableState = MFrontVariableState()
    variables_new :: MFrontVariableState = MFrontVariableState()

    external_variables :: MFrontExternalVariableState = MFrontExternalVariableState()
    
    behaviour :: MFrontInterface.behaviour.BehaviourAllocated
    behaviour_data :: MFrontInterface.behaviour.BehaviourDataAllocated
end

function Materials.integrate_material!(material::MFrontMaterial)
    behaviour = material.behaviour
    behaviour_data = material.behaviour_data

    mgis_bv.set_time_increment!(behaviour_data, material.ddrivers.time)
    mgis_bv.revert(material.behaviour_data)

    # setting the external variables (like temperature)
    for j in 1:length(material.external_variables.names)
        if material.external_variables.names[j] != ""
            mgis_bv.set_external_state_variable!(mgis_bv.get_s1(behaviour_data), material.external_variables.names[j], material.external_variables.values[j])
        end
    end

    # passing strain from material struct to the mfront interface
    dstrain = tovoigt(material.ddrivers.strain; offdiagscale=2.0)
    # now reorder from voigt 11, 22, 33, 23, 13, 12 -> 11, 22, 33, 12, 13, 23
    # and use Mandel notation (scaling with sqrt(2.0))
    # https://en.wikipedia.org/wiki/Voigt_notation#Mandel_notation
    mfront_dstrain = tovoigt(frommandel(SymmetricTensor{2, 3}, [dstrain[1], dstrain[2], dstrain[3], dstrain[6], dstrain[5], dstrain[4]]))
    gradients = mgis_bv.get_gradients(mgis_bv.get_final_state(behaviour_data))
    for j in 1:6
        gradients[j] += mfront_dstrain[j]
    end

    # tell mfront interface to calculate the tangent
    # if K[0] is greater than 3.5, the consistent tangent operator must be computed.
    dummy = zeros(36)
    dummy[1] = 4.0
    mgis_bv.set_tangent_operator!(behaviour_data, dummy)

    mgis_bv.integrate(behaviour_data, behaviour)

    stress = [mgis_bv.get_thermodynamic_forces(mgis_bv.get_final_state(behaviour_data))[k] for k in 1:6]
    jacobian = reshape([mgis_bv.get_tangent_operator(behaviour_data)[k] for k in 1:36], 6, 6)
    
    # now reorder to voigt 11, 22, 33, 12, 13, 23 -> 11, 22, 33, 23, 13, 12
    stress = [stress[1], stress[2], stress[3], stress[6], stress[5], stress[4]]
    stress = frommandel(SymmetricTensor{2, 3}, stress)

    r1 = jacobian[4, :]
    r3 = jacobian[6, :]
    jacobian[4, :] .= r3
    jacobian[6, :] .= r1
    c1 = jacobian[:, 4]
    c3 = jacobian[:, 6]
    jacobian[:, 4] .= c3
    jacobian[:, 6] .= c1
    jacobian = frommandel(SymmetricTensor{4, 3}, jacobian)

    variables_new = MFrontVariableState(stress=stress, jacobian=jacobian)
    material.variables_new = variables_new
end

function Materials.update_material!(material::MFrontMaterial)
    mgis_bv.update(material.behaviour_data)

    material.drivers += material.ddrivers
    material.variables = material.variables_new

    reset_material!(material)
end

function Materials.reset_material!(material::MFrontMaterial)
    material.ddrivers = typeof(material.ddrivers)()
    material.variables_new = typeof(material.variables_new)()
end

# other material_* functions are used from FEMMaterials

import FEMMaterials: update_ip!
import FEMBase: Element, Hex8

"""
Initializes integration point `ip` for data storage of both `variables` and `drivers` at simulation start `time`.
"""
function FEMMaterials.material_preprocess_analysis!(material::MFrontMaterial, element::Element{Hex8}, ip, time)
    update_ip!(material, ip, time)
    # Read parameter values
    values = element("external_variables", ip, time)
    material.external_variables = MFrontExternalVariableState(material.external_variables.names, values)
end

"""
Initializes integration point `ip` for data storage of both `variables` and `drivers` at simulation start `time`.
Updates external variables, e.g. temperature, stored in `ip` to material
"""
function FEMMaterials.material_preprocess_increment!(material::MFrontMaterial, element::Element{Hex8}, ip, time)

    values = element("external_variables", ip, time)
    material.external_variables = MFrontExternalVariableState(material.external_variables.names, values)

    # Update time increment
    dtime = time - material.drivers.time
    material.ddrivers.time = dtime

    return nothing
end
