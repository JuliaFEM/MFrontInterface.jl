@testset "show methods" begin
    b = load("data/libBehaviour.so","Norton",mbv.Tridimensional)
    BehaviourAllocated_out = @capture_out show(b)
    BehaviourAllocated_expected = "behaviour Norton in shared library Behaviour for modelling hypothesis Tridimensional generated from Norton.mfront using TFEL version: 3.3.0-dev."
    @test BehaviourAllocated_out == BehaviourAllocated_expected

    d = BehaviourData(b)
    RealsVectorRef_out = @capture_out show(get_internal_state_variables(get_initial_state(d)))
    RealsVectorRef_expected = "7-element RealsVector\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n"
    @test RealsVectorRef_expected == RealsVectorRef_out

end
