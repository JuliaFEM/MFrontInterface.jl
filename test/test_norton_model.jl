@testset "Norton model" begin
println(pwd())
# shorten namespace name
mbv = MFrontInterface.behaviour

# comparison criterion
eps = 1.e-12

b = mbv.load("data/libBehaviour.so","Norton", mbv.Tridimensional)

d = mbv.BehaviourData(b)
o = mbv.get_variable_offset(mbv.get_internal_state_variables(b),
                            "EquivalentViscoplasticStrain",
                            mbv.get_hypothesis(b))

# strain increment per time step
de = 5.e-5
# time step
mbv.set_time_increment!(d,180)

# setting the temperature
mbv.set_external_state_variable!(mbv.get_final_state(d),
                                 "Temperature", 293.15)

# copy d.s1 in d.s0
mbv.update(d)
mbv.get_gradients(mbv.get_final_state(d))[1] = de

# equivalent plastic strain
p = [mbv.get_internal_state_variables(mbv.get_initial_state(d))[o]]

# integrate the behaviour
for i in 1:20
    mbv.integrate(d, b)
    mbv.update(d)
    mbv.get_gradients(mbv.get_final_state(d))[1] += de
    push!(p,mbv.get_internal_state_variables(mbv.get_final_state(d))[o])
end

# reference values
pref = readdlm("data/norton_comparison_results.txt")

# check results
for i in 1:20
    @test abs(p[i]-pref[i])<eps
end

end
