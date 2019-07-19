@testset "show methods" begin
    b = load("data/libBehaviour.so","Norton",mbv.Tridimensional)
    BehaviourAllocated_out = @capture_out show(b)
    BehaviourAllocated_expected = "libBehaviour: generated from Norton.mfront\nname of the behaviour: Norton\nTFEL version: 3.3.0-dev"
    @test BehaviourAllocated_out == BehaviourAllocated_expected

end
