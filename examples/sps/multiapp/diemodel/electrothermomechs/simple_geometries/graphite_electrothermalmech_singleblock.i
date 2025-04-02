## Units in the input file: m-Pa-s-K

#initial_porosity = 0.38
initial_temperature = 300 #roughly 600C where the pyrometer kicks in

[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = false
  order = SECOND
[]

[Mesh]
  [top_square]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 20
    ny = 20
    xmax = 0.0005
    ymin = 0.0005
    ymax = 0.001
    boundary_name_prefix = upper_plunger
    elem_type = QUAD8
  []
  [top_square_block]
    type = SubdomainIDGenerator
    input = top_square
    subdomain_id = 1
  []
  [two_blocks]
    type = MeshCollectionGenerator
    inputs = 'top_square_block'
  []
  [block_rename]
    type = RenameBlockGenerator
    input = two_blocks
    old_block = '1'
    new_block = 'upper_plunger'
  []
  [inner_centerpoint]
    type = BoundingBoxNodeSetGenerator
    input = block_rename
    bottom_left = '0.0    0.00074 0'
    top_right = '0.25e-5 0.000755 0'
    new_boundary = 'centerpoint'
  []
  [outer_centerpoint]
    type = BoundingBoxNodeSetGenerator
    input = inner_centerpoint
    bottom_left = '0.00049    0.00074 0'
    top_right = '5.25e-5 0.000755 0'
    new_boundary = 'outer_centerpoint'
  []
  coord_type = RZ
  patch_update_strategy = iteration
  patch_size = 10
[]

[Problem]
  type = ReferenceResidualProblem
  reference_vector = 'ref'
  extra_tag_vectors = 'ref'
[]

[Variables]
  [temperature]
    initial_condition = ${initial_temperature}
  []
  [electric_potential]
  []
[]

[AuxVariables]
  [vonmises_stress]
    family = MONOMIAL
    order = FIRST
  []

  # [thermal_conductivity_aeh]
  #   initial_condition = 0.4
  # []
  [specific_heat_capacity_va]
    initial_condition = 842.2 # at 1500K #568.73 at 1000K #447.281 # at 293K
  []
  [density_va]
    initial_condition = 3106.2 ##5010.0*(1-${initial_porosity}) #in kg/m^3
  []
  [heat_transfer_radiation]
  []
  [thermal_conductivity]
    family = MONOMIAL
    order = FIRST
    block = 'upper_plunger'
  []

  [sigma_aeh]
    initial_condition = 2.0e-10 #in units eV/((nV)^2-s-nm)
  []
  # [electrical_conductivity]
  #   family = MONOMIAL
  #   order = FIRST
  #   block = 'upper_plunger'
  # []
  [microapp_potential]
    #converted to microapp electronVolts units
  []
  [E_x]
    order = FIRST
    family = MONOMIAL
  []
  [E_y]
    order = FIRST
    family = MONOMIAL
  []
  [graphite_current_density]
    order = FIRST
    family = MONOMIAL
  []
  [current_density_J]
    family = NEDELEC_ONE
    order = FIRST
  []
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [graphite]
        strain = FINITE
        add_variables = true
        use_automatic_differentiation = true
        generate_output = 'strain_xx strain_xy strain_yy strain_zz stress_xx stress_xy stress_yy stress_zz'
        extra_vector_tags = 'ref'
        # eigenstrain_names = 'graphite_thermal_expansion'
        block = 'upper_plunger'
      []
    []
  []
[]

[Kernels]
  [HeatDiff_graphite]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = thermal_conductivity #use parsed material property, hope it works
    extra_vector_tags = 'ref'
    block = 'upper_plunger'
  []
  [HeatTdot_graphite]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = heat_capacity #use parsed material property
    density_name = graphite_density
    extra_vector_tags = 'ref'
    block = 'upper_plunger'
  []
  [JouleHeating_graphite]
    type = ADJouleHeatingSource
    variable = temperature
    elec = electric_potential
    electrical_conductivity = electrical_conductivity
    # use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'upper_plunger'
  []
  [electric_graphite]
    type = ADMatDiffusion
    variable = electric_potential
    diffusivity = electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'upper_plunger'
  []
[]

[AuxKernels]
  [vonmises_stress]
    type = ADRankTwoScalarAux
    variable = vonmises_stress
    rank_two_tensor = stress
    scalar_type = VonMisesStress
  []

  [heat_transfer_radiation]
    type = ParsedAux
    variable = heat_transfer_radiation
    boundary = 'upper_plunger_right'
    coupled_variables = 'temperature'
    constant_names = 'boltzmann epsilon temperature_farfield'
    constant_expressions = '5.67e-8 0.85 300.0' #roughly room temperature, which is probably too cold
    expression = '-boltzmann*epsilon*(temperature^4-temperature_farfield^4)'
  []
  [electrical_conductivity]
    type = ADMaterialRealAux
    variable = electrical_conductivity
    property = electrical_conductivity
    block = 'upper_plunger'
  []
  [thermal_conductivity]
    type = ADMaterialRealAux
    variable = thermal_conductivity
    property = thermal_conductivity
    block = 'upper_plunger'
  []

  [E_x]
    type = VariableGradientComponent
    variable = E_x
    gradient_variable = electric_potential
    component = x
    block = 'upper_plunger'
  []
  [E_y]
    type = VariableGradientComponent
    variable = E_y
    gradient_variable = electric_potential
    component = y
    block = 'upper_plunger'
  []
  [graphite_current_density]
    type = ParsedAux
    variable = graphite_current_density
    coupled_variables = 'electrical_conductivity E_y'
    expression = '-1.0*electrical_conductivity*E_y'
    block = 'upper_plunger'
  []
  [current_density_J]
    type = ADCurrentDensity
    variable = current_density_J
    potential = electric_potential
  []
[]

[BCs]
  [centerline_no_dispx]
    type = ADDirichletBC
    preset = true
    variable = disp_x
    value = 0
    boundary = 'upper_plunger_left'
  []
  [fixed_in_y]
    type = ADDirichletBC
    preset = true
    variable = disp_y
    value = 0
    boundary = 'centerpoint'
  []
  [bottom_pressure_ydirection]
    type = ADPressure
    variable = disp_y
    boundary = 'upper_plunger_bottom'
    function = 20.7e6 #'if(t<1, 20.7e6*t, 20.7e6)'
  []
  [top_pressure_ydirection]
    type = ADPressure
    variable = disp_y
    boundary = 'upper_plunger_top'
    function = 20.7e6 #'if(t<1, 20.7e6*t, 20.7e6)'
  []

  # [top_temperature]
  #   type = ADFunctionDirichletBC
  #   variable = temperature
  #   function = 'if(t<1100, ${initial_temperature} + 50.0/60.0*t, 1800)' #stand-in for a 50C/min heating rate)'
  #   boundary = 'top_upper_plunger'
  # []
  [external_surface]
    type = CoupledVarNeumannBC
    boundary = 'upper_plunger_right'
    variable = temperature
    v = heat_transfer_radiation
  []

  [electric_top]
    type = ADFunctionDirichletBC
    variable = electric_potential
    boundary = 'upper_plunger_top'
    function = 'if(t<20.0, 4.0e-3*t, 0.08)'
    # value = 1.5 #2.5 #'3.5' ## V #+1.0e-6*t'
  []
  [electric_bottom]
    type = ADDirichletBC
    variable = electric_potential
    boundary = 'upper_plunger_bottom'
    value = 0.0 #1.0 #0.0
  []
[]

[Functions]
  [graphite_thermal_conductivity_fcn]
    type = ParsedFunction
    expression = 29.0 #'-4.418e-12*t^4+2.904e-8*t^3-4.688e-5*t^2-0.0316*t+119.659'
  []
  # [yttria_thermal_conductivity_fcn] #from the multiapp
  #   type = ParsedFunction
  #   expression = '3214.46/(t-147.73)'
  # []
  # [harmonic_mean_thermal_conductivity]
  #   type = ParsedFunction
  #   expression = '2*(-4.418e-12*t^4+2.904e-8*t^3-4.688e-5*t^2-0.0316*t+119.659)*(3214.46/(t-147.73))/((-4.418e-12*t^4+2.904e-8*t^3-4.688e-5*t^2-0.0316*t+119.659)+(3214.46/(t-147.73)))'
  #   # symbol_names = 'k_graphite k_yttria'
  #   # symbol_values = 'graphite_thermal_conductivity_fcn yttria_thermal_conductivity_fcn'
  # []

  [graphite_electrical_conductivity_fcn]
    type = ParsedFunction
    expression = 1.1e5 #'1.0/(-2.705e-15*t^3+1.263e-11*t^2-1.836e-8*t+1.813e-5)'
  []
  # [yttria_electrical_conductivity_fcn]
  #   type = ParsedFunction
  #   # symbol_names = porosity
  #   # symbol_values = initial_porosity
  #   expression = '(1-0.62)*2.0025e4*exp(-1.61/8.617343e-5/t)'
  # []
  # [harmonic_mean_electrical_conductivity]
  #   type = ParsedFunction
  #   expression = '2*(1.0/(-2.705e-15*t^3+1.263e-11*t^2-1.836e-8*t+1.813e-5))*((1)*2.0025e4*exp(-1.61/8.617343e-5/t))/((1.0/(-2.705e-15*t^3+1.263e-11*t^2-1.836e-8*t+1.813e-5))+((1)*2.0025e4*exp(-1.61/8.617343e-5/t)))'
  #   # symbol_names = 'k_graphite k_yttria'
  #   # symbol_values = 'graphite_thermal_conductivity_fcn yttria_thermal_conductivity_fcn'
  # []
[]

[Materials]
  [graphite_elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 1.08e10 #in Pa, 10.8 GPa, Cincotti
    poissons_ratio = 0.33
    block = 'upper_plunger'
  []
  [graphite_stress]
    type = ADComputeFiniteStrainElasticStress
    block = 'upper_plunger'
  []
  # [graphite_thermal_expansion]
  #   type = ADGraphiteThermalExpansionEigenstrain
  #   # type = ADComputeThermalExpansionEigenstrain
  #   # thermal_expansion_coeff = 3.5e-6
  #   eigenstrain_name = graphite_thermal_expansion
  #   stress_free_temperature = 300
  #   temperature = temperature
  #   block = 'upper_plunger'
  # []
  [graphite_density]
    type = ADGenericConstantMaterial
    prop_names = 'graphite_density'
    prop_values = 1.750e3 #in kg/m^3 from Cincotti et al 2007, Table 2, doi:10.1002/aic
    block = 'upper_plunger'
  []
  [graphite_thermal]
    type = ADGraphiteThermal
    temperature = temperature
    block = 'upper_plunger'
  []
  [graphite_electrical_conductivity]
    type = ADParsedMaterial
    property_name = electrical_conductivity
    coupled_variables = 'temperature'
    expression = '1.0/(-2.705e-15*temperature^3+1.263e-11*temperature^2-1.836e-8*temperature+1.813e-5)'
    output_properties = electrical_conductivity
    outputs = 'exodus'
    block = 'upper_plunger'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  automatic_scaling = true
  line_search = 'none'
  compute_scaling_once = false

  # petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap'
  # petsc_options_value = 'asm          ilu         1'
  # petsc_options_iname = '-ksp_max_it -ksp_gmres_restart -pc_type -snes_max_funcs -sub_pc_factor_levels'
  # petsc_options_value = ' 100         100                asm      1000000         1'
  # petsc_options_iname = '-pc_type -snes_linesearch_type -pc_factor_shift_type -pc_factor_shift_amount'
  # petsc_options_value = 'lu       basic                 NONZERO               1e-15'

  # petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  # petsc_options_value = '  asm         101              preonly         ilu        2'
  # petsc_options = '-snes_converged_reason -ksp_converged_reason -options_left -ksp_monitor_singular_value'

  #bison options
  # petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = ' lu       superlu_dist'

  nl_rel_tol = 2e-5 #was 1e-10, for temperature only
  nl_abs_tol = 2e-12 #was 1e-10, before that 1e-12
  nl_max_its = 20
  l_max_its = 50
  dtmin = 1.0e-3

  end_time = 1 #900 #15 minutes, rule of thumb from Dennis is 10 minutes
  [Quadrature]
    order = FIFTH
    side_order = SEVENTH
  []
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.05
    optimal_iterations = 8
    iteration_window = 2
  []
[]

[Postprocessors]
  [stress_xx]
    type = ElementAverageValue
    variable = stress_xx
  []
  [strain_xx]
    type = ElementAverageValue
    variable = strain_xx
  []
  [stress_yy]
    type = ElementAverageValue
    variable = stress_yy
  []
  [strain_yy]
    type = ElementAverageValue
    variable = strain_yy
  []
  [vonmises_stress]
    type = ElementAverageValue
    variable = vonmises_stress
  []
  [temperature_pp]
    type = AverageNodalVariableValue
    variable = temperature
  []
  [graphite_thermal_conductivity]
    type = ElementAverageValue
    variable = thermal_conductivity
    block = 'upper_plunger'
  []
  [graphite_sigma]
    type = ElementAverageValue
    variable = electrical_conductivity
    block = 'upper_plunger'
  []

  # [yttria_thermal_conductivity]
  #   type = ElementAverageValue
  #   variable = yttria_thermal_conductivity
  #   block = powder_compact
  # []
  # [temperature_powder_midpoint]
  #   type = PointValue
  #   variable = temperature
  #   point = '0.00025 0.00025 0'
  # []
  # [temperature_graphite_midpoint]
  #   type = PointValue
  #   variable = temperature
  #   point = '0.00025 0.00075 0'
  # []
  # [electric_potential_powder_midpoint]
  #   type = PointValue
  #   variable = electric_potential
  #   point = '0.00025 0.00025 0'
  # []
  # [electric_potential_graphite_midpoint]
  #   type = PointValue
  #   variable = electric_potential
  #   point = '0.00025 0.00075 0'
  # []
[]

[Outputs]
  csv = true
  exodus = true
  perf_graph = true
[]
