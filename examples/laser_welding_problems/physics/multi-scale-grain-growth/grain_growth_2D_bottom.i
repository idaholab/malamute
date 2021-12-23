# This simulation predicts GB migration of a 2D copper polycrystal with 100 grains represented with 18 order parameters
# Mesh adaptivity and time step adaptivity are used
# An AuxVariable is used to calculate the grain boundary locations
# Postprocessors are used to record time step and the number of grains

[Mesh]
  # Mesh block.  Meshes can be read in or automatically generated
  type = GeneratedMesh
  dim = 2 # Problem dimension
  nx = 11 # Number of elements in the x-direction
  ny = 11 # Number of elements in the y-direction
  xmin = 0    # minimum x-coordinate of the mesh
  xmax = 1e5 # maximum x-coordinate of the mesh
  ymin = 0    # minimum y-coordinate of the mesh
  ymax = 1e5 # maximum y-coordinate of the mesh
  elem_type = QUAD4  # Type of elements used in the mesh
  uniform_refine = 3 # Initial uniform refinement of the mesh

  parallel_type = replicated # Periodic BCs
[]

[GlobalParams]
  # Parameters used by several kernels that are defined globally to simplify input file
  op_num = 8 # Number of order parameters used
  var_name_base = gr # Base name of grains
[]

[Variables]
  # Variable block, where all variables in the simulation are declared
  [./PolycrystalVariables]
  [../]
[]

[UserObjects]
  [./voronoi]
    type = PolycrystalVoronoi
    grain_num = 100 # Number of grains
    rand_seed = 20
  [../]
  [./grain_tracker]
    type = GrainTracker
    threshold = 0.2
    connecting_threshold = 0.08
    compute_halo_maps = true # Only necessary for displaying HALOS
  [../]
[]

[ICs]
  [./PolycrystalICs]
    [./PolycrystalColoringIC]
      polycrystal_ic_uo = voronoi
    [../]
  [../]
[]

[AuxVariables]
  # Dependent variables
  [./bnds]
    # Variable used to visualize the grain boundaries in the simulation
  [../]
  [./unique_grains]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./var_indices]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./ghost_regions]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./halos]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./T_1000K]
    initial_condition = 0.298
  [../]
  [./T]
    initial_condition = 298
  [../]
[]

[Kernels]
  # Kernel block, where the kernels defining the residual equations are set up.
  [./PolycrystalKernel]
    # Custom action creating all necessary kernels for grain growth.  All input parameters are up in GlobalParams
  [../]
[]

[AuxKernels]
  # AuxKernel block, defining the equations used to calculate the auxvars
  [./bnds_aux]
    # AuxKernel that calculates the GB term
    type = BndsCalcAux
    variable = bnds
    execute_on = 'initial timestep_end'
  [../]
  [./unique_grains]
    type = FeatureFloodCountAux
    variable = unique_grains
    flood_counter = grain_tracker
    field_display = UNIQUE_REGION
    execute_on = 'initial timestep_end'
  [../]
  [./var_indices]
    type = FeatureFloodCountAux
    variable = var_indices
    flood_counter = grain_tracker
    field_display = VARIABLE_COLORING
    execute_on = 'initial timestep_end'
  [../]
  [./ghosted_entities]
    type = FeatureFloodCountAux
    variable = ghost_regions
    flood_counter = grain_tracker
    field_display = GHOSTED_ENTITIES
    execute_on = 'initial timestep_end'
  [../]
  [./halos]
    type = FeatureFloodCountAux
    variable = halos
    flood_counter = grain_tracker
    field_display = HALOS
    execute_on = 'initial timestep_end'
  [../]
  [./temp_conversion]
    type = ParsedAux
    args = 'T_1000K'
    function = '1000 * T_1000K'
    variable = T
  [../]
[]

[BCs]
  # Boundary Condition block
  [./Periodic]
    [./top_bottom]
      auto_direction = 'x y'
    [../]
  [../]
[]

[Materials]
  [./CuGrGr]
    # Material properties
    type = GBEvolution
    T = T # Specified temperature profile
    wGB = 1e3 # Width of the diffuse GB
    GBmob0 = 3.19e-4 #m^4(Js) for copper from Schoenfelder1997
    Q = 0.23 #eV for copper from Schoenfelder1997
    GBenergy = 0.708 #J/m^2 from Schoenfelder1997
  [../]
[]

[Postprocessors]
  # Scalar postprocessors
  [./dt]
    # Outputs the current time step
    type = TimestepSize
  [../]
  [./num_dofs]
    type = NumDOFs
  [../]
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient # Type of executioner, here it is transient with an adaptive time step
  scheme = bdf2 # Type of time integration (2nd order backward euler), defaults to 1st order backward euler

  #Preconditioned JFNK (default)
  solve_type = 'NEWTON'

  # Uses newton iteration to solve the problem.
  petsc_options_iname = '-pc_type -ksp_gmres_restart'
  petsc_options_value = 'asm 101'

  l_max_its = 30 # Max number of linear iterations
  l_tol = 1e-4 # Relative tolerance for linear solves
  nl_max_its = 12 # Max number of nonlinear iterations
  nl_rel_tol = 1e-10 # Absolute tolerance for nonlienar solves

  start_time = 0.0
  end_time = 4800

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 25 # Initial time step.  In this simulation it changes.
    optimal_iterations = 8 # Time step will adapt to maintain this number of nonlinear iterations
  [../]

  [./Adaptivity]
    # Block that turns on mesh adaptivity. Note that mesh will never coarsen beyond initial mesh (before uniform refinement)
    initial_adaptivity = 2 # Number of times mesh is adapted to initial condition
    refine_fraction = 0.7 # Fraction of high error that will be refined
    coarsen_fraction = 0.1 # Fraction of low error that will coarsened
    max_h_level = 4 # Max number of refinements used, starting from initial mesh (before uniform refinement)
  [../]
[]

[Outputs]
  exodus = true # Exodus file will be outputted
  csv = true
  [./console]
    type = Console
    max_rows = 20 # Will print the 20 most recent postprocessor values to the screen
  [../]
[]
