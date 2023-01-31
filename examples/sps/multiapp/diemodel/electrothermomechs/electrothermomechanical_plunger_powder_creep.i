## Units in the input file: m-Pa-s-K

initial_temperature=300 #roughly 600C where the pyrometer kicks in

[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = false
  order = SECOND
[]

[Mesh]
  file = stepped_plunger_powder_2d.e
  coord_type = RZ
  construct_side_list_from_node_list = true
  patch_update_strategy = iteration
  patch_size = 20
  # ghosting_patch_size = 5*patch_size
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
    block = 'upper_plunger lower_plunger die_wall'
  []

  [sigma_aeh]
    initial_condition = 2.0e-10 #in units eV/((nV)^2-s-nm)
  []
  # [electrical_conductivity]
  #   family = MONOMIAL
  #   order = FIRST
  #   block = 'upper_plunger lower_plunger die_wall'
  # []
  [microapp_potential] #converted to microapp electronVolts units
  []
  [E_x]
    order = FIRST
    family = MONOMIAL
  []
  [E_y]
    order = FIRST
    family = MONOMIAL
  []
  [yttria_current_density]
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

[Modules]
  [TensorMechanics/Master]
    [graphite]
      strain = FINITE
      add_variables = true
      use_automatic_differentiation = true
      generate_output = 'strain_xx strain_xy strain_yy strain_zz stress_xx stress_xy stress_yy stress_zz'
      extra_vector_tags = 'ref'
      eigenstrain_names = 'graphite_thermal_expansion'
      block = 'upper_plunger lower_plunger die_wall'
    []
    [yttria]
      strain = FINITE
      add_variables = true
      use_automatic_differentiation = true
      generate_output = 'strain_xx strain_xy strain_yy strain_zz stress_xx stress_xy stress_yy stress_zz'
      extra_vector_tags = 'ref'
      eigenstrain_names = 'yttria_thermal_expansion'
      block = 'powder_compact'
    []
  []
[]

[Kernels]
  [HeatDiff_graphite]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = thermal_conductivity
    extra_vector_tags = 'ref'
    block = 'upper_plunger lower_plunger die_wall'
  []
  [HeatTdot_graphite]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = heat_capacity
    density_name = graphite_density
    extra_vector_tags = 'ref'
    block = 'upper_plunger lower_plunger die_wall'
  []
  [JouleHeating_graphite]
    type = ADJouleHeatingSource
    variable = temperature
    elec = electric_potential
    electrical_conductivity = electrical_conductivity
    use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'upper_plunger lower_plunger die_wall'
  []
  [electric_graphite]
    type = ADMatDiffusion
    variable = electric_potential
    diffusivity = electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'upper_plunger lower_plunger die_wall'
  []

  [HeatDiff_yttria]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = yttria_thermal_conductivity #use parsed material property, hope it works
    extra_vector_tags = 'ref'
    block = powder_compact
  []
  [HeatTdot_yttria]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = yttria_specific_heat_capacity #use parsed material property
    density_name = yttria_density
    extra_vector_tags = 'ref'
    block = powder_compact
  []
  [JouleHeating_yttria]
    type = ADJouleHeatingSource
    variable = temperature
    elec = electric_potential
    electrical_conductivity = electrical_conductivity
    use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = powder_compact
  []
  [electric_yttria]
    type = ADMatDiffusion
    variable = electric_potential
    diffusivity = electrical_conductivity
    use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = powder_compact
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
    boundary = 'outer_die_wall'
    coupled_variables = 'temperature'
    constant_names = 'boltzmann epsilon temperature_farfield'  #published emissivity for graphite is 0.85
    constant_expressions = '5.67e-8 0.85 300.0' #roughly room temperature, which is probably too cold
    expression = '-boltzmann*epsilon*(temperature^4-temperature_farfield^4)'
  []
  [thermal_conductivity]
    type = ADMaterialRealAux
    variable = thermal_conductivity
    property = thermal_conductivity
    block = 'upper_plunger lower_plunger die_wall'
  []

  [microapp_potential]
    type = ParsedAux
    variable = microapp_potential
    coupled_variables = electric_potential
    expression = 'electric_potential*1e9' #convert from V to nV
    block = 'powder_compact'
  []
  [E_x]
    type = VariableGradientComponent
    variable = E_x
    gradient_variable = electric_potential
    component = x
    # block = 'powder_compact'
  []
  [E_y]
    type = VariableGradientComponent
    variable = E_y
    gradient_variable = electric_potential
    component = y
    # block = 'powder_compact'
  []
  [yttria_current_density]
    type = ParsedAux
    variable = yttria_current_density
    coupled_variables = 'electrical_conductivity E_y'
    expression = '-1.0*electrical_conductivity*E_y'
    block = 'powder_compact'
  []
  [graphite_current_density]
    type = ParsedAux
    variable = graphite_current_density
    coupled_variables = 'electrical_conductivity E_y'
    expression = '-1.0*electrical_conductivity*E_y'
    block = 'upper_plunger lower_plunger die_wall'
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
    boundary = 'centerline_powder_compact centerline_upper_plunger centerline_lower_plunger'
  []
  [fixed_in_y]
    type = ADDirichletBC
    preset = true
    variable = disp_y
    value = 0
    boundary = 'axial_centerpoint centerpoint_outer_die_wall' #centerpoint_inner_die_wall
  []
  [bottom_pressure_ydirection]
    type = ADPressure
    variable = disp_y
    boundary = 'bottom_lower_plunger'
    function = 'if(t<1.0, (20.7e6/1.0)*t, 20.7e6)'
  []
  [top_pressure_ydirection]
    type = ADPressure
    variable = disp_y
    boundary = 'top_upper_plunger'
    function = 'if(t<1.0, (20.7e6/1.0)*t, 20.7e6)'
  []

  [external_surface]
    type = CoupledVarNeumannBC
    boundary = 'outer_die_wall'
    variable = temperature
    v = heat_transfer_radiation
  []

  [electric_top]
    type = ADFunctionDirichletBC
    variable = electric_potential
    boundary = 'top_upper_plunger'
    function = 'if(t<1.0,0.0, if(t<21.0, 4.0e-2*t, 0.8))' #maximum value is 0.38V to maintain 10V/m drop
  []
  [electric_bottom]
    type = ADDirichletBC
    variable = electric_potential
    boundary = 'bottom_lower_plunger'
    value = 0.0 #1.0 #0.0
  []
[]

[Functions]
  [graphite_thermal_conductivity_fcn]
    type = ParsedFunction
    expression = '-4.418e-12*t^4+2.904e-8*t^3-4.688e-5*t^2-0.0316*t+119.659'
  []
  # [yttria_thermal_conductivity_fcn] #from the multiapp
  #   type = ParsedFunction
  #   expression = '3214.46/(t-147.73)'
  # []
  [harmonic_mean_thermal_conductivity]
    type = ParsedFunction
    expression = '2*(-4.418e-12*t^4+2.904e-8*t^3-4.688e-5*t^2-0.0316*t+119.659)*(3214.46/(t-147.73))/((-4.418e-12*t^4+2.904e-8*t^3-4.688e-5*t^2-0.0316*t+119.659)+(3214.46/(t-147.73)))'
    # symbol_names = 'k_graphite k_yttria'
    # symbol_values = 'graphite_thermal_conductivity_fcn yttria_thermal_conductivity_fcn'
  []

  [graphite_electrical_conductivity_fcn]
    type = ParsedFunction
    expression = '1.0/(-2.705e-15*t^3+1.263e-11*t^2-1.836e-8*t+1.813e-5)'
  []
  # [electrical_conductivity_fcn]
  #   type = ParsedFunction
  #   # symbol_names = porosity
  #   # symbol_values = initial_porosity
  #   expression = '(1-0.62)*2.0025e4*exp(-1.61/8.617343e-5/t)'
  # []
  [harmonic_mean_electrical_conductivity]
    type = ParsedFunction
    expression = '2*(1.0/(-2.705e-15*t^3+1.263e-11*t^2-1.836e-8*t+1.813e-5))*((1)*2.0025e4*exp(-1.61/8.617343e-5/t))/((1.0/(-2.705e-15*t^3+1.263e-11*t^2-1.836e-8*t+1.813e-5))+((1)*2.0025e4*exp(-1.61/8.617343e-5/t)))'
    # symbol_names = 'k_graphite k_yttria'
    # symbol_values = 'graphite_thermal_conductivity_fcn yttria_thermal_conductivity_fcn'
  []
[]

[Contact]
  [upper_plunger_powder_mechanical]
    primary = bottom_upper_plunger
    secondary = top_powder_compact
    formulation = kinematic
    model = frictionless
    penalty = 1e14 #1e4 is good in the mm-MPa system
    normal_smoothing_distance = 0.1 #was 0.1 in mm-MPa system
    normalize_penalty = true
  []
  [upper_plunger_die_mechanical]
    secondary = outer_upper_plunger
    primary = inner_die_wall
    formulation = kinematic
    model = frictionless
    penalty = 1e14 #isotropic yttria block takes 1e12
    normal_smoothing_distance = 0.1
    normalize_penalty = true
  []
  [powder_die_mechanical]
    primary = inner_die_wall
    secondary = outer_powder_compact
    formulation = kinematic
    model = frictionless
    penalty = 1e14 #isotropic yttria block takes 1e12
    normal_smoothing_distance = 0.1
    normalize_penalty = true
  []
  [lower_plunger_die_mechanical]
    primary = inner_die_wall
    secondary = outer_lower_plunger
    formulation = kinematic
    model = frictionless
    penalty = 1e14 #isotropic yttria block takes 1e12
    normal_smoothing_distance = 0.1
    normalize_penalty = true
  []
  [powder_bottom_plunger_mechanical]
    secondary = bottom_powder_compact
    primary = top_lower_plunger
    formulation = kinematic
    model = frictionless
    penalty = 1e14 #isotropic takes 1e12
    normal_smoothing_distance = 0.1
    normalize_penalty = true
  []
[]

[ThermalContact]
  [lower_plunger_die_electric]
    type = GapHeatTransfer
    primary = inner_die_wall
    secondary = outer_lower_plunger
    variable = electric_potential
    quadrature = true
    emissivity_primary = 0.0 #0.85 #cincotti 2007, table 2
    emissivity_secondary = 0.0 #0.85
    # gap_geometry_type = PLATE # Not for vertical surfaces
    gap_conductivity_function = 'graphite_electrical_conductivity_fcn'
    gap_conductivity_function_variable = temperature
    normal_smoothing_distance = 0.1
  []
  [top_plunger_die_electric]
    type = GapHeatTransfer
    primary = inner_die_wall
    secondary = outer_upper_plunger
    variable = electric_potential
    quadrature = true
    emissivity_primary = 0.0 #0.85 #cincotti 2007, table 2
    emissivity_secondary = 0.0 #0.85
    # gap_geometry_type = PLATE # Not for vertical surfaces
    gap_conductivity_function = 'graphite_electrical_conductivity_fcn'
    gap_conductivity_function_variable = temperature
    normal_smoothing_distance = 0.1
  []
  [upper_plunger_powder_electric]
    type = GapHeatTransfer
    primary = bottom_upper_plunger
    secondary = top_powder_compact
    variable = electric_potential
    quadrature = true
    emissivity_primary = 0.0 #0.85 #cincotti 2007, table 2
    emissivity_secondary = 0.0 #0.85
    gap_geometry_type = PLATE
    gap_conductivity_function = 'harmonic_mean_electrical_conductivity'
    gap_conductivity_function_variable = temperature
    normal_smoothing_distance = 0.1
  []
  [powder_die_electric]
    type = GapHeatTransfer
    primary = inner_die_wall
    secondary = outer_powder_compact
    variable = electric_potential
    quadrature = true
    emissivity_primary = 0.0 #0.85 #cincotti 2007, table 2
    emissivity_secondary = 0.0 #0.85
    # gap_geometry_type = PLATE # Not for vertical surfaces
    gap_conductivity_function = 'harmonic_mean_electrical_conductivity'
    gap_conductivity_function_variable = temperature
    normal_smoothing_distance = 0.1
  []
  [powder_bottom_plunger_electric]
    type = GapHeatTransfer
    primary = top_lower_plunger
    secondary = bottom_powder_compact #expect more heat transfer from the die to the powder
    variable = electric_potential
    quadrature = true
    emissivity_primary = 0.0 #0.85 #cincotti 2007, table 2
    emissivity_secondary = 0.0 #0.85 #assume no radiation heat transfer because no gap
    gap_geometry_type = PLATE
    gap_conductivity_function = 'harmonic_mean_electrical_conductivity'
    gap_conductivity_function_variable = temperature
    normal_smoothing_distance = 0.1
  []

  [lower_plunger_die_thermal]
    type = GapHeatTransfer
    primary = inner_die_wall
    secondary = outer_lower_plunger
    variable = temperature
    quadrature = true
    emissivity_primary = 0.85 #cincotti 2007, table 2
    emissivity_secondary = 0.85
    # gap_geometry_type = PLATE # Not for vertical surfaces
    gap_conductivity_function = 'graphite_thermal_conductivity_fcn'
    gap_conductivity_function_variable = temperature
    normal_smoothing_distance = 0.1
  []
  [top_plunger_die_thermal]
    type = GapHeatTransfer
    primary = inner_die_wall
    secondary = outer_upper_plunger
    variable = temperature
    quadrature = true
    emissivity_primary = 0.85 #cincotti 2007, table 2
    emissivity_secondary = 0.85
    # gap_geometry_type = PLATE # Not for vertical surfaces
    gap_conductivity_function = 'graphite_thermal_conductivity_fcn'
    gap_conductivity_function_variable = temperature
    normal_smoothing_distance = 0.1
  []
  [upper_plunger_powder_thermal]
    type = GapHeatTransfer
    primary = bottom_upper_plunger
    secondary = top_powder_compact
    variable = temperature
    quadrature = true
    emissivity_primary = 0.85 #cincotti 2007, table 2
    emissivity_secondary = 0.85
    gap_geometry_type = PLATE
    gap_conductivity_function = 'harmonic_mean_thermal_conductivity'
    gap_conductivity_function_variable = temperature
    normal_smoothing_distance = 0.1
  []
  [powder_die_thermal]
    type = GapHeatTransfer
    primary = inner_die_wall
    secondary = outer_powder_compact
    variable = temperature
    quadrature = true
    emissivity_primary = 0.85 #cincotti 2007, table 2
    emissivity_secondary = 0.85
    # gap_geometry_type = PLATE # Not for vertical surfaces
    gap_conductivity_function = 'harmonic_mean_thermal_conductivity'
    gap_conductivity_function_variable = temperature
    normal_smoothing_distance = 0.1
  []
  [powder_bottom_plunger_thermal]
    type = GapHeatTransfer
    primary = top_lower_plunger
    secondary = bottom_powder_compact #expect more heat transfer from the die to the powder
    variable = temperature
    quadrature = true
    emissivity_primary = 0.85 #cincotti 2007, table 2
    emissivity_secondary = 0.85 #assume no radiation heat transfer because no gap
    gap_geometry_type = PLATE
    gap_conductivity_function = 'harmonic_mean_thermal_conductivity'
    gap_conductivity_function_variable = temperature
    normal_smoothing_distance = 0.1
  []
[]


[Materials]
  [graphite_elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 1.08e10 #in Pa, 10.8 GPa, Cincotti
    poissons_ratio = 0.33
    block = 'upper_plunger lower_plunger die_wall'
  []
  [graphite_stress]
    type = ADComputeFiniteStrainElasticStress
    block = 'upper_plunger lower_plunger die_wall'
  []
  [graphite_thermal_expansion]
    type = ADGraphiteThermalExpansionEigenstrain
    eigenstrain_name = graphite_thermal_expansion
    stress_free_temperature = ${initial_temperature}
    temperature = temperature
    block = 'upper_plunger lower_plunger die_wall'
  []
  [graphite_density]
    type = ADGenericConstantMaterial
    prop_names = 'graphite_density'
    prop_values = 1.750e3 #in kg/m^3 from Cincotti et al 2007, Table 2, doi:10.1002/aic
    block = 'upper_plunger lower_plunger die_wall'
  []
  [graphite_thermal]
    type = ADGraphiteThermal
    temperature = temperature
    output_properties = 'thermal_conductivity heat_capacity'
    block = 'upper_plunger lower_plunger die_wall'
  []
  # [graphite_electrical]
  #   type = ADGraphiteElectricalConductivity
  #   temperature = temperature
  #   output_properties = all
  #   outputs = 'csv exodus'
  #   block = 'upper_plunger lower_plunger die_wall'
  # []
  # [graphite_electrical_resistivity]
  #   type = ADParsedMaterial
  #   property_name = electrical_resistivity
  #   material_property_names = electrical_conductivity
  #   expression = '1 / electrical_conductivity'
  #   output_properties = electrical_conductivity
  #   outputs = 'csv exodus'
  #   block = 'upper_plunger lower_plunger die_wall'
  # []
  [graphite_electrical_conductivity]
    type = ADParsedMaterial
    property_name = electrical_conductivity
    coupled_variables = 'temperature'
    expression = '1.0/(-2.705e-15*temperature^3+1.263e-11*temperature^2-1.836e-8*temperature+1.813e-5)'
    output_properties = electrical_conductivity
    outputs = 'csv exodus'
    block = 'upper_plunger lower_plunger die_wall'
  []

  [yttria_elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    # youngs_modulus = 1.16e11 #in Pa for fully dense part
    youngs_modulus = 1.38e10 #in Pa assuming 62% initial density and theoretical coeff. from Phani and Niyogi (1987)
    poissons_ratio = 0.36
    block = powder_compact
  []
  [yttria_stress]
    type = ADComputeMultipleInelasticStress
    block = powder_compact
    inelastic_models = yttria_creep_model
  []
  [yttria_creep_model]
    type = ADPowerLawCreepStressUpdate
    block = powder_compact
    coefficient = 3.75e-7 # from Al's work
    n_exponent = 0.714 # from Al's work
    activation_energy = 0.0
    use_substep = true
    absolute_tolerance = 5e-9
  []
  [yttria_thermal_expansion]
    type = ADComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 9.3e-6  # from https://doi.org/10.1111/j.1151-2916.1957.tb12619.x
    eigenstrain_name = yttria_thermal_expansion
    stress_free_temperature = 300
    temperature = temperature
  []
  [yttria_thermal_conductivity]
    type = ADParsedMaterial
    coupled_variables = 'temperature'
    expression = '3214.46 / (temperature - 147.73)' #in W/(m-K) #Given from Larry's curve fitting, data from Klein and Croft, JAP, v. 38, p. 1603 and UC report "For Computer Heat Conduction Calculations - A compilation of thermal properties data" by A.L. Edwards, UCRL-50589 (1969)
    # coupled_variables = 'thermal_conductivity_aeh'
    # expression = 'thermal_conductivity_aeh' #in W/(m-K) directly, for now
    property_name = 'yttria_thermal_conductivity'
    output_properties = yttria_thermal_conductivity
    outputs = 'csv exodus'
    block = powder_compact
  []
  [yttria_specific_heat_capacity]
    type = ADParsedMaterial
    property_name = yttria_specific_heat_capacity
    coupled_variables = 'specific_heat_capacity_va'
    expression = 'specific_heat_capacity_va' #in J/(K-kg)
    # output_properties = yttria_specific_heat_capacity
    # outputs = 'csv exodus'
    block = powder_compact
  []
  [yttria_density]
    type = ADParsedMaterial
    property_name = 'yttria_density'
    coupled_variables = 'density_va'
    expression = 'density_va'
    # output_properties = yttria_density
    # outputs = 'csv exodus'
    block = powder_compact
  []
  [electrical_conductivity]
    type = ADParsedMaterial
  #   coupled_variables = 'sigma_aeh'
  #   expression = 'sigma_aeh*1.602e8' #converts to units of J/(V^2-m-s)
    property_name = 'electrical_conductivity'
    output_properties = electrical_conductivity
    outputs = 'exodus csv'
    block = powder_compact
    # type = ADDerivativeParsedMaterial
    # property_name = electrical_conductivity
    coupled_variables = 'temperature'
    constant_names =       'Q_elec  kB            prefactor_solid  initial_porosity'
    constant_expressions = '1.61    8.617343e-5        1.25e-4           0.38'
    expression = '(1-initial_porosity) * prefactor_solid * exp(-Q_elec/kB/temperature) * 1.602e8' # in eV/(nV^2 s nm) per chat with Larry, last term converts to units of J/(V^2-m-s)
  []
[]

[Dampers]
  [disp_x_damp]
    type = ElementJacobianDamper
    # max_increment = 2.0e-4
    use_displaced_mesh = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  automatic_scaling = true
  line_search = 'none'
  # compute_scaling_once = false

  # force running options
  # petsc_options_iname = '-pc_type -snes_linesearch_type -pc_factor_shift_type -pc_factor_shift_amount'
  # petsc_options_value = 'lu       basic                 NONZERO               1e-15'

  # #mechanical contact options
  # petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = ' lu       superlu_dist'
  petsc_options = '-snes_converged_reason -ksp_converged_reason'

  nl_forced_its = 1
  nl_rel_tol = 2e-5 #was 1e-10, for temperature only
  nl_abs_tol = 2e-12 #was 1e-10, before that 1e-12
  nl_max_its = 20
  l_max_its = 50
  dtmin = 1.0e-4

  end_time = 600 #900 #15 minutes, rule of thumb from Dennis is 10 minutes
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
    block = 'upper_plunger lower_plunger die_wall'
  []
  [graphite_sigma]
    type = ElementAverageValue
    variable = electrical_conductivity
    block = 'upper_plunger lower_plunger die_wall'
  []

  [yttria_thermal_conductivity]
    type = ElementAverageValue
    variable = yttria_thermal_conductivity
    block = powder_compact
  []
  [yttria_sigma]
    type = ElementAverageValue
    variable = electrical_conductivity
    block = powder_compact
  []
[]


[Outputs]
  csv = true
  exodus = true
  perf_graph = true
  [ckpt]
    type =Checkpoint
    interval = 1
    num_files = 2
  []
[]
