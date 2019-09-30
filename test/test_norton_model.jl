# This file is a part of JuliaFEM.
# License is MIT: see https://github.com/JuliaFEM/MFrontInterface.jl/blob/master/LICENSE

using MFrontInterface
using DelimitedFiles
using Suppressor
using Test
lpath = MFrontInterface.lpath

# shorten namespace name
mbv = MFrontInterface.behaviour

# comparison criterion
eps = 1.e-12

b = load("test_norton_model/libBehaviour.so","Norton", mbv.Tridimensional)

d = BehaviourData(b)
o = get_variable_offset(get_internal_state_variables(b),
                        "EquivalentViscoplasticStrain",
                        get_hypothesis(b))

# strain increment per time step
de = 5.e-5
# time step
set_time_increment!(d,180)

# setting the temperature
set_external_state_variable!(get_final_state(d), "Temperature", 293.15)

# copy d.s1 in d.s0
update(d)
get_gradients(get_final_state(d))[1] = de

# equivalent plastic strain
p = [get_internal_state_variables(get_initial_state(d))[o]]

# integrate the behaviour
for i in 1:20
    integrate(d, b)
    update(d)
    get_gradients(get_final_state(d))[1] += de
    push!(p,get_internal_state_variables(get_final_state(d))[o])
end

# reference values
pref = readdlm("test_norton_model/norton_comparison_results.txt")

# check results
for i in 1:20
    @test isapprox(p[i],pref[i]; atol=eps)
end

