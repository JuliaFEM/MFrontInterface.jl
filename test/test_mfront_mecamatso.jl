# This file is a part of JuliaFEM.
# License is MIT: see https://github.com/JuliaFEM/MFrontInterface.jl/blob/master/LICENSE

using MFrontInterface
using Test
using Materials, Tensors, FEMMaterials, FEMBase, Test

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

analysis, problem, element, bc_elements, ip = get_one_element_material_analysis(:(Main.MaterialTest))

temperature = 293.15
update!(element, "external_variables", [temperature])

times = [0.0, 1.0, 2.0, 3.0]
loads = [0.0, 1.0e-3, -1.0e-3, 1.0e-3]
loading = AxialStrainLoading(times, loads)
update_bc_elements!(bc_elements, loading)
analysis.properties.t1 = maximum(times)

run!(analysis)
s33 = [tovoigt(ip("stress", t))[3] for t in times]
s33_expected = 1e6*[0.0, 100.0, -100.0, 100.0]
@test isapprox(s33, s33_expected; rtol=1.0e-2)
