# This file is a part of JuliaFEM.
# License is MIT: see https://github.com/JuliaFEM/MFrontInterface.jl/blob/master/LICENSE

using MFrontInterface
using Test
using Tensors

mgis_bv = MFrontInterface.behaviour

function MaterialTest()
    lib_path = "test_plasticity/libBehaviour.so"
    behaviour_name = "IsotropicLinearHardeningPlasticity"
    hypothesis = mgis_bv.Tridimensional

    behaviour = load(lib_path, behaviour_name, hypothesis)
    behaviour_data = BehaviourData(behaviour)

    ext_variable_names = [mgis_bv.get_name(mgis_bv.get_external_state_variables(behaviour)[i]) for i in 1:mgis_bv.length(mgis_bv.get_external_state_variables(behaviour))]
    ext_variable_values = zeros(length(ext_variable_names))
    ext_vatiable_state = MFrontExternalVariableState(names=ext_variable_names, values=ext_variable_values)
    
    return MFrontMaterial(behaviour=behaviour, behaviour_data=behaviour_data, external_variables=ext_vatiable_state)
end

mat = MaterialTest()

d = mat.behaviour_data
o = get_variable_offset(get_internal_state_variables(mat.behaviour),
                        "EquivalentPlasticStrain",
                        get_hypothesis(mat.behaviour))

dstrain_dtime = fromvoigt(SymmetricTensor{2,3,Float64}, 1e-3*[1.0, -0.3, -0.3, 0.0, 0.0, 0.0]; offdiagscale=2.0)
ddrivers = MFrontDriverState(time = 0.25, strain = 0.25*dstrain_dtime)
mat.ddrivers = ddrivers

integrate_material!(mat)
update_material!(mat)
@test isapprox(mat.variables.stress, fromvoigt(SymmetricTensor{2,3}, 1.0e6*[50.0, 0.0, 0.0, 0.0, 0.0, 0.0]))

mat.ddrivers = ddrivers
integrate_material!(mat)
update_material!(mat)
@test isapprox(mat.variables.stress, fromvoigt(SymmetricTensor{2,3}, 1.0e6*[100.0, 0.0, 0.0, 0.0, 0.0, 0.0]))
@test isapprox(get_internal_state_variables(get_initial_state(d))[o], 0.0; atol=1.0e-6)

dstrain_dtime = fromvoigt(SymmetricTensor{2,3,Float64}, 1e-3*[1.0, -0.5, -0.5, 0.0, 0.0, 0.0]; offdiagscale=2.0)
ddrivers = MFrontDriverState(time = 0.25, strain = 0.25*dstrain_dtime)
mat.ddrivers = ddrivers
integrate_material!(mat)
update_material!(mat)
@test isapprox(mat.variables.stress, fromvoigt(SymmetricTensor{2,3}, 1.0e6*[100.0, 0.0, 0.0, 0.0, 0.0, 0.0]); atol=1.0e-6)
@test isapprox(get_internal_state_variables(get_initial_state(d))[o], 0.25*1.0e-3)

dstrain_dtime = fromvoigt(SymmetricTensor{2,3,Float64}, -1e-3*[1.0, -0.3, -0.3, 0.0, 0.0, 0.0]; offdiagscale=2.0)
ddrivers = MFrontDriverState(time = 0.25, strain = 0.25*dstrain_dtime)
mat.ddrivers = ddrivers
integrate_material!(mat)
update_material!(mat)
@test isapprox(mat.variables.stress, fromvoigt(SymmetricTensor{2,3}, 1.0e6*[50.0, 0.0, 0.0, 0.0, 0.0, 0.0]); atol=1.0e-6)

dstrain_dtime = (-0.75*fromvoigt(SymmetricTensor{2,3,Float64}, 1e-3*[1.0, -0.3, -0.3, 0.0, 0.0, 0.0]; offdiagscale=2.0)
                -0.25*fromvoigt(SymmetricTensor{2,3,Float64}, 1e-3*[1.0, -0.5, -0.5, 0.0, 0.0, 0.0]; offdiagscale=2.0))
ddrivers = MFrontDriverState(time = 1.0, strain = dstrain_dtime)
mat.ddrivers = ddrivers
integrate_material!(mat)
integrate_material!(mat)
update_material!(mat)
@test isapprox(mat.variables.stress, fromvoigt(SymmetricTensor{2,3}, 1.0e6*[-100.0, 0.0, 0.0, 0.0, 0.0, 0.0]))
