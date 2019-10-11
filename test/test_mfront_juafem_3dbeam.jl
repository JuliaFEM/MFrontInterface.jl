# This file is a part of JuliaFEM.
# License is MIT: see https://github.com/JuliaFEM/MFrontInterface.jl/blob/master/LICENSE

# # von Mises plasticity by MFrontInterface.jl
#
# This is modified version of the [original JuAFEM.jl von Mises plasticity example](http://kristofferc.github.io/JuAFEM.jl/dev/examples/plasticity/)

# ## Material parameters and state variables
#
# Start by loading some necessary packages

using JuAFEM, SparseArrays, LinearAlgebra, Printf, Materials, MFrontInterface
using Tensors, Plots, DelimitedFiles, Test

# Next, we define a constructor for the material instance.

function MFrontTest()
    lib_path = "test_plasticity/libBehaviour.so"
    behaviour_name = "IsotropicLinearHardeningPlasticity"
    hypothesis = MFrontInterface.behaviour.Tridimensional

    behaviour = load(lib_path, behaviour_name, hypothesis)
    behaviour_data = BehaviourData(behaviour)

    ext_variable_names = [mgis_bv.get_name(mgis_bv.get_external_state_variables(behaviour)[i]) for i in 1:mgis_bv.length(mgis_bv.get_external_state_variables(behaviour))]
    ext_variable_values = zeros(length(ext_variable_names))
    ext_variable_values = [293.15] # temperature
    ext_vatiable_state = MFrontExternalVariableState(names=ext_variable_names, values=ext_variable_values)

    return MFrontMaterial(behaviour=behaviour, behaviour_data=behaviour_data, external_variables=ext_vatiable_state)
end

m = MFrontTest()

m.external_variables.names


# For later use, during the post-processing step, we define a function to compute the von Mises effective stress.

function vonMises(σ)
    s = dev(σ)
    return sqrt(3.0/2.0 * s ⊡ s)
end;

# ## FE-problem
#
# What follows are methods for assembling and and solving the FE-problem.

function create_values(interpolation)
    # setup quadrature rules
    qr      = QuadratureRule{3,RefTetrahedron}(2)
    face_qr = QuadratureRule{2,RefTetrahedron}(3)

    # create geometric interpolation (use the same as for u)
    interpolation_geom = Lagrange{3,RefTetrahedron,1}()

    # cell and facevalues for u
    cellvalues_u = CellVectorValues(qr, interpolation, interpolation_geom)
    facevalues_u = FaceVectorValues(face_qr, interpolation, interpolation_geom)

    return cellvalues_u, facevalues_u
end;

# Add degrees of freedom

function create_dofhandler(grid, interpolation)
    dh = DofHandler(grid)
    dim = 3
    push!(dh, :u, dim, interpolation) # add a displacement field with 3 components
    close!(dh)
    return dh
end

# Boundary conditions

function create_bc(dh, grid)
    dbcs = ConstraintHandler(dh)
    # Clamped on the left side
    dofs = [1, 2, 3]
    dbc = Dirichlet(:u, getfaceset(grid, "left"), (x,t) -> [0.0, 0.0, 0.0], dofs)
    JuAFEM.add!(dbcs, dbc)
    close!(dbcs)
    return dbcs
end;

# Assembling of element contributions
# - Residual vector r
# - Tangent stiffness K

function doassemble(cellvalues::CellVectorValues{dim},
                    facevalues::FaceVectorValues{dim}, K::SparseMatrixCSC, grid::Grid,
                    dh::DofHandler, u, states, t) where {dim}
    r = zeros(ndofs(dh))
    assembler = start_assemble(K, r)
    nu = getnbasefunctions(cellvalues)
    re = zeros(nu)     # element residual vector
    ke = zeros(nu, nu) # element tangent matrix

    for (cell, state) in zip(CellIterator(dh), states)
        fill!(ke, 0)
        fill!(re, 0)
        eldofs = celldofs(cell)
        ue = u[eldofs]
        assemble_cell!(ke, re, cell, cellvalues, facevalues, grid,
                       ue, state, t)
        JuAFEM.assemble!(assembler, eldofs, re, ke)
    end
    return K, r
end

# Compute element contribution to the residual and the tangent.

function assemble_cell!(Ke, re, cell, cellvalues, facevalues, grid,
                        ue, state, t)
    n_basefuncs = getnbasefunctions(cellvalues)
    reinit!(cellvalues, cell)

    for q_point in 1:getnquadpoints(cellvalues)
        # For each integration point, compute stress and material stiffness
        ∇u = function_gradient(cellvalues, q_point, ue)
        ϵ = symmetric(∇u) # Total strain
        material = state[q_point]
        strainvec = tovoigt(ϵ; offdiagscale=2.0)
        strainvec = [ϵ[1,1], ϵ[2,2], ϵ[3,3],
                 2.0*ϵ[2,3], 2.0*ϵ[1,3], 2.0*ϵ[1,2]]
        dstrain = ϵ - material.drivers.strain
        material.ddrivers = MFrontDriverState(strain = dstrain)
        integrate_material!(material)
        D = material.variables_new.jacobian
        σ = material.variables_new.stress

        dΩ = getdetJdV(cellvalues, q_point)
        for i in 1:n_basefuncs
            δϵ = symmetric(shape_gradient(cellvalues, q_point, i))

            re[i] += (δϵ ⊡ σ) * dΩ # add internal force to residual
            for j in 1:i
                Δϵ = symmetric(shape_gradient(cellvalues, q_point, j))
                Ke[i, j] += δϵ ⊡ D ⊡ Δϵ * dΩ
            end
        end
    end
    symmetrize_lower!(Ke)

    # Add traction as a negative contribution to the element residual `re`:
    for face in 1:nfaces(cell)
        if onboundary(cell, face) && (cellid(cell), face) ∈ getfaceset(grid, "right")
            reinit!(facevalues, cell, face)
            for q_point in 1:getnquadpoints(facevalues)
                dΓ = getdetJdV(facevalues, q_point)
                for i in 1:n_basefuncs
                    δu = shape_value(facevalues, q_point, i)
                    re[i] -= (δu ⋅ t) * dΓ
                end
            end
        end
    end

end

# Helper function to symmetrize the material tangent

function symmetrize_lower!(K)
    for i in 1:size(K,1)
        for j in i+1:size(K,1)
            K[i,j] = K[j,i]
        end
    end
end;

# Define a function which solves the FE-problem.

function solve()

    L = 10.0 # beam length [m]
    w = 1.0  # beam width [m]
    h = 1.0  # beam height[m]
    n_timesteps = 10
    u_max = zeros(n_timesteps)
    traction_magnitude = 1.e7 * range(0.5, 1.0, length=n_timesteps)

    # Create geometry, dofs and boundary conditions
    n = 2
    nels = (10n, n, 2n) # number of elements in each spatial direction
    P1 = Vec((0.0, 0.0, 0.0))  # start point for geometry
    P2 = Vec((L, w, h))        # end point for geometry
    grid = generate_grid(Tetrahedron, nels, P1, P2)
    interpolation = Lagrange{3, RefTetrahedron, 1}() # Linear tet with 3 unknowns/node

    dh = create_dofhandler(grid, interpolation) # JuaFEM helper function
    dbcs = create_bc(dh, grid) # create Dirichlet boundary-conditions

    cellvalues, facevalues = create_values(interpolation)

    # Pre-allocate solution vectors, etc.
    n_dofs = ndofs(dh)  # total number of dofs
    u  = zeros(n_dofs)  # solution vector
    Δu = zeros(n_dofs)  # displacement correction
    r = zeros(n_dofs)   # residual
    K = create_sparsity_pattern(dh); # tangent stiffness matrix

    # Create material states. One array for each cell, where each element is an array of material-
    # states - one for each integration point
    nqp = getnquadpoints(cellvalues)
    states = [[MFrontTest() for _ in 1:nqp] for _ in 1:getncells(grid)]

    # Newton-Raphson loop
    NEWTON_TOL = 1e-5 # 1 N
    print("\n Starting Netwon iterations:\n")

    for timestep in 1:n_timesteps
        t = timestep # actual time (used for evaluating d-bndc)
        traction = Vec((0.0, 0.0, traction_magnitude[timestep]))
        newton_itr = -1
        print("\n Time step @time = $timestep:\n")
        JuAFEM.update!(dbcs, t) # evaluates the D-bndc at time t
        JuAFEM.apply!(u, dbcs)  # set the prescribed values in the solution vector

        K, r = doassemble(cellvalues, facevalues, K, grid, dh, u,
                             states, traction);
        norm_r0 = norm(r[JuAFEM.free_dofs(dbcs)])

        while true; newton_itr += 1

            if newton_itr > 10
                error("Reached maximum Newton iterations, aborting")
                break
            end
            K, r = doassemble(cellvalues, facevalues, K, grid, dh, u,
                             states, traction);
            norm_r = norm(r[JuAFEM.free_dofs(dbcs)])

            print("Iteration: $newton_itr \tresidual: $(@sprintf("%.8f", norm_r/norm_r0))\n")
            if norm_r/norm_r0 < NEWTON_TOL
                break
            end

            apply_zero!(K, r, dbcs)
            Δu = Symmetric(K) \ r
            u -= Δu
        end # of while

        # Update all the material states after we have reached equilibrium
        for material in states
            foreach(update_material!, material)
        end
        u_max[timestep] = max(abs.(u)...) # maximum displacement in current timestep
    end # of time stepping

    return u_max, traction_magnitude
end

u_max, traction_magnitude = solve();

# reference values

u_ref = readdlm("test_mfront_juafem/juafem_3d_beam_comparison_results.txt")

# check results

for i in 1:length(u_ref)
    @test isapprox(u_max[i], u_ref[i]; atol=sqrt(Base.eps()))
end

# ## Finally let's plot a figure

plot(
    vcat(0.0, u_max),                # add the origin as a point
    vcat(0.0, traction_magnitude),
    linewidth=2,
    title="Traction-displacement",
    label=[""],
    markershape=:auto
    )
ylabel!("Traction [Pa]")
xlabel!("Maximum deflection [m]")
