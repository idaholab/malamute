## Units in the input file: m-Pa-s-K

initial_temperature=300 #roughly 600C where the pyrometer kicks in

[GlobalParams]
  order = SECOND
[]

[Mesh]
  file = stepped_plunger_powder_2d.e
  coord_type = RZ
  construct_side_list_from_node_list = true
  patch_update_strategy = iteration
  patch_size = 20
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
    value = '-4.418e-12*t^4+2.904e-8*t^3-4.688e-5*t^2-0.0316*t+119.659'
  []
  # [yttria_thermal_conductivity_fcn] #from the multiapp
  #   type = ParsedFunction
  #   value = '3214.46/(t-147.73)'
  # []
  [harmonic_mean_thermal_conductivity]
    type = ParsedFunction
    value = '2*(-4.418e-12*t^4+2.904e-8*t^3-4.688e-5*t^2-0.0316*t+119.659)*(3214.46/(t-147.73))/((-4.418e-12*t^4+2.904e-8*t^3-4.688e-5*t^2-0.0316*t+119.659)+(3214.46/(t-147.73)))'
    # vars = 'k_graphite k_yttria'
    # vals = 'graphite_thermal_conductivity_fcn yttria_thermal_conductivity_fcn'
  []

  [graphite_electrical_conductivity_fcn]
    type = ParsedFunction
    value = '1.0/(-2.705e-15*t^3+1.263e-11*t^2-1.836e-8*t+1.813e-5)'
  []
  # [electrical_conductivity_fcn]
  #   type = ParsedFunction
  #   # vars = porosity
  #   # vals = initial_porosity
  #   value = '(1-0.62)*2.0025e4*exp(-1.61/8.617343e-5/t)'
  # []
  [harmonic_mean_electrical_conductivity]
    type = ParsedFunction
    value = '2*(1.0/(-2.705e-15*t^3+1.263e-11*t^2-1.836e-8*t+1.813e-5))*((1)*2.0025e4*exp(-1.61/8.617343e-5/t))/((1.0/(-2.705e-15*t^3+1.263e-11*t^2-1.836e-8*t+1.813e-5))+((1)*2.0025e4*exp(-1.61/8.617343e-5/t)))'
    # vars = 'k_graphite k_yttria'
    # vals = 'graphite_thermal_conductivity_fcn yttria_thermal_conductivity_fcn'
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
  #   f_name = electrical_resistivity
  #   material_property_names = electrical_conductivity
  #   function = '1 / electrical_conductivity'
  #   output_properties = electrical_conductivity
  #   outputs = 'csv exodus'
  #   block = 'upper_plunger lower_plunger die_wall'
  # []
  [graphite_electrical_conductivity]
    type = ADParsedMaterial
    f_name = electrical_conductivity
    args = 'temperature'
    function = '1.0/(-2.705e-15*temperature^3+1.263e-11*temperature^2-1.836e-8*temperature+1.813e-5)'
    output_properties = electrical_conductivity
    outputs = 'csv exodus'
    block = 'upper_plunger lower_plunger die_wall'
  []

  [yttria_thermal_conductivity]
    type = ADParsedMaterial
    args = 'temperature'
    function = '3214.46 / (temperature - 147.73)' #in W/(m-K) #Given from Larry's curve fitting, data from Klein and Croft, JAP, v. 38, p. 1603 and UC report "For Computer Heat Conduction Calculations - A compilation of thermal properties data" by A.L. Edwards, UCRL-50589 (1969)
    # args = 'thermal_conductivity_aeh'
    # function = 'thermal_conductivity_aeh' #in W/(m-K) directly, for now
    f_name = 'yttria_thermal_conductivity'
    output_properties = yttria_thermal_conductivity
    outputs = 'csv exodus'
    block = powder_compact
  []
  [yttria_specific_heat_capacity]
    type = ADParsedMaterial
    f_name = yttria_specific_heat_capacity
    args = 'specific_heat_capacity_va'
    function = 'specific_heat_capacity_va' #in J/(K-kg)
    # output_properties = yttria_specific_heat_capacity
    # outputs = 'csv exodus'
    block = powder_compact
  []
  [yttria_density]
    type = ADParsedMaterial
    f_name = 'yttria_density'
    args = 'density_va'
    function = 'density_va'
    # output_properties = yttria_density
    # outputs = 'csv exodus'
    block = powder_compact
  []
  [electrical_conductivity]
    type = ADParsedMaterial
  #   args = 'sigma_aeh'
  #   function = 'sigma_aeh*1.602e8' #converts to units of J/(V^2-m-s)
    f_name = 'electrical_conductivity'
    output_properties = electrical_conductivity
    outputs = 'exodus csv'
    block = powder_compact
    # type = ADDerivativeParsedMaterial
    # f_name = electrical_conductivity
    args = 'temperature'
    constant_names =       'Q_elec  kB            prefactor_solid  initial_porosity'
    constant_expressions = '1.61    8.617343e-5        1.25e-4           0.38'
    function = '(1-initial_porosity) * prefactor_solid * exp(-Q_elec/kB/temperature) * 1.602e8' # in eV/(nV^2 s nm) per chat with Larry, last term converts to units of J/(V^2-m-s)
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
  nl_rel_tol = 1e-4 #was 1e-10, for temperature only
  nl_abs_tol = 2e-12 #was 1e-10, before that 1e-12
  nl_max_its = 20
  l_max_its = 50
  dtmin = 1.0e-3

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
