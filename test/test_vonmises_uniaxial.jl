using MFrontInterface
using Materials
using DelimitedFiles
using Suppressor
using Tensors
using Test

dtime = 0.25
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

times = [mat.drivers.time]
stresses = [copy(tovoigt(mat.variables.stress))]
stresses_expected = [[50.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                     [100.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                     [150.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                     [100.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                     [-100.0, 0.0, 0.0, 0.0, 0.0, 0.0]]
dstrain11 = 1e-9*dtime
strains_expected = [[dstrain11, -0.3*dstrain11, -0.3*dstrain11, 0.0, 0.0, 0.0],
                    [2*dstrain11, -0.3*dstrain11*2, -0.3*dstrain11*2, 0.0, 0.0, 0.0],
                    [3*dstrain11, -0.3*dstrain11*2 - 0.3*dstrain11, -0.3*dstrain11*2 - 0.3*dstrain11, 0.0, 0.0, 0.0],
                    [2*dstrain11, -0.3*dstrain11 - 0.3*dstrain11, -0.3*dstrain11 - 0.3*dstrain11, 0.0, 0.0, 0.0],
                    [-2*dstrain11, 0.3*dstrain11*2, 0.3*dstrain11*2, 0.0, 0.0, 0.0]]
dtimes = [dtime, dtime, dtime, dtime, 1.0]
dstrains11 = [dstrain11, dstrain11, dstrain11, -dstrain11, -4*dstrain11]
for i in 1:length(dtimes)
    dstrain11 = dstrains11[i]
    dtime = dtimes[i]
    uniaxial_increment!(mat, dstrain11, dtime)
    update_material!(mat)
    @test isapprox(tovoigt(mat.variables.stress), stresses_expected[i])
    #@info(tovoigt(mat.drivers.strain; offdiagscale=2.0), strains_expected[i])
    @test isapprox(tovoigt(mat.drivers.strain; offdiagscale=2.0), strains_expected[i])
end
