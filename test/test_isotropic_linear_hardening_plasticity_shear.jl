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

E = 200.0e9
nu = 0.3
syield = 100.0e6

times = [0.0]
loads = [0.0]
dt = 0.5
G = 0.5*E/(1+nu)

ea = 2*syield/(sqrt(3)*G)
# Go to elastic border
push!(times, times[end]+dt)
push!(loads, loads[end] + ea*dt)
 # Proceed to plastic flow
push!(times, times[end]+dt)
push!(loads, loads[end] + ea*dt)
 # Reverse direction
push!(times, times[end]+dt)
push!(loads, loads[end] - ea*dt)
 # Continue and pass yield criterion
push!(times, times[end]+dt)
push!(loads, loads[end] - 2*ea*dt)
stresses = [copy(tovoigt(mat.variables.stress))]
for i=2:length(times)
    dtime = times[i]-times[i-1]
    dstrain12 = loads[i]-loads[i-1]
    dstrain = [0.0, 0.0, 0.0, 0.0, 0.0, dstrain12]
    dstrain_ = fromvoigt(SymmetricTensor{2,3,Float64}, dstrain; offdiagscale=2.0)
    ddrivers = MFrontDriverState(time = dtime, strain = dstrain_)
    mat.ddrivers = ddrivers
    integrate_material!(mat)
    update_material!(mat)
    push!(stresses, copy(tovoigt(mat.variables.stress)))
end

for i in 1:length(times)
    @test isapprox(stresses[i][1:5], zeros(5); atol=1e-6)
end
s12 = [s[6] for s in stresses]

s12_expected = [0.0, syield/sqrt(3.0), syield/sqrt(3.0), 0.0, -syield/sqrt(3.0)]
@test isapprox(s12, s12_expected; rtol=1.0e-2)
