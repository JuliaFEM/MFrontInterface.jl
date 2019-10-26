using MFrontInterface, Test, Tensors, Materials, Suppressor

norton = raw"""
@DSL Implicit;
@Author Thomas Helfer;
@Date 3 / 08 / 2018;
@Behaviour NortonTest;
@Description {
  "This file implements the Norton law "
  "using the StandardElastoViscoplasticity brick"
}

@ModellingHypotheses{".+"};
@Epsilon 1.e-16;

@Brick StandardElastoViscoPlasticity{
  stress_potential : "Hooke" {young_modulus : 150e9, poisson_ratio : 0.3},
  inelastic_flow : "Norton" {criterion : "Mises", A : 8.e-67, n : 8.2, K : 1}
};
""";

path = mfront(norton)
@test isfile(path)

mat = MFrontMaterialModel(lib_path=path, behaviour_name="NortonTest")
times = [mat.drivers.time]
stresses = [copy(tovoigt(mat.variables.stress))]
stresses_expected = [[37.5, 0.0, 0.0, 0.0, 0.0, 0.0],
                     [75.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                     [112.5, 0.0, 0.0, 0.0, 0.0, 0.0],
                     [75.0, 0.0, 0.0, 0.0, 0.0, 0.0],
                     [-75.0, 0.0, 0.0, 0.0, 0.0, 0.0]]
dtime = 0.25
dstrain11 = 1e-9*dtime
strains_expected = [[dstrain11, -0.3*dstrain11, -0.3*dstrain11, 0.0, 0.0, 0.0],
                    [2*dstrain11, -0.6*dstrain11, -0.6*dstrain11, 0.0, 0.0, 0.0],
                    [3*dstrain11, -0.9*dstrain11, -0.9*dstrain11, 0.0, 0.0, 0.0],
                    [2*dstrain11, -0.6*dstrain11, -0.6*dstrain11, 0.0, 0.0, 0.0],
                    [-2*dstrain11, 0.6*dstrain11, 0.6*dstrain11, 0.0, 0.0, 0.0]]
dtimes = [dtime, dtime, dtime, dtime, 1.0]
dstrains11 = [dstrain11, dstrain11, dstrain11, -dstrain11, -4*dstrain11]
for i in 1:length(dtimes)
    dstrain11 = dstrains11[i]
    dtime = dtimes[i]
    uniaxial_increment!(mat, dstrain11, dtime)
    update_material!(mat)
    #@info(tovoigt(mat.variables.stress), stresses_expected[i])
    @test isapprox(tovoigt(mat.variables.stress), stresses_expected[i])
    #@info(tovoigt(mat.drivers.strain; offdiagscale=2.0), strains_expected[i])
    @test isapprox(tovoigt(mat.drivers.strain; offdiagscale=2.0), strains_expected[i])
end
