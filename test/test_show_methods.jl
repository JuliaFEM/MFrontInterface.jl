using MFrontInterface
using DelimitedFiles
using Suppressor
using Test

b = load("test_show_methods/libBehaviour.so","Norton",mbv.Tridimensional)
BehaviourAllocated_out = @capture_out show(b)
BehaviourAllocated_expected = "behaviour Norton in shared library test_show_methods/libBehaviour.so for modelling hypothesis Tridimensional generated from Norton.mfront using TFEL version: 3.3.0-dev."
@test BehaviourAllocated_out == BehaviourAllocated_expected

d = BehaviourData(b)
RealsVectorRef_out = @capture_out show(get_internal_state_variables(get_initial_state(d)))
RealsVectorRef_expected = "7-element RealsVector\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n"
@test RealsVectorRef_expected == RealsVectorRef_out

StringsVectorAllocated_out = @capture_out show(get_parameters(b))
StringsVectorAllocated_expected = "11-element StringsVector\n epsilon\n YoungModulus\n PoissonRatio\n RelativeValueForTheEquivalentStressLowerBoundDefinition\n K\n E\n A\n minimal_time_step_scaling_factor\n maximal_time_step_scaling_factor\n theta\n numerical_jacobian_epsilon\n"
@test StringsVectorAllocated_expected == StringsVectorAllocated_out

set_external_state_variable!(get_final_state(d), "Temperature", 293.15)
VariablesVectorAllocated_out = @capture_out show(get_external_state_variables(b))
VariablesVectorAllocated_expected = "1-element VariablesVector\n Temperature\n"
@test VariablesVectorAllocated_expected == VariablesVectorAllocated_out
