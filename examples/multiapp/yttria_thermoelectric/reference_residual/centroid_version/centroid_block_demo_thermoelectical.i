initial_temperature=1350

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 40 #100
  ny = 40
  xmax = 0.004 #0.4 cm #0.01 #1cm
  ymax = 0.004 #0.4cm (to get square elements)
  second_order = true
[]

[Problem]
  coord_type = RZ
  type = ReferenceResidualProblem
  reference_vector = 'ref'
  extra_tag_vectors = 'ref'
[]


[Variables]
  [temperature]
    initial_condition = ${initial_temperature}
    order = SECOND
  []
  [yttria_potential]
    order = SECOND
  []
[]

[AuxVariables]
  [thermal_conductivity_aeh]
    initial_condition = 0.4
  []
  [specific_heat_capacity_va]
    initial_condition = 842.2 # at 1500K #568.73 at 1000K #447.281 # at 293K
  []
  [heat_transfer_radiation]
  []
  [density_va]
    initial_condition = 1.0e3 #just a guess
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
  [microapp_current_density]
    order = FIRST
    family = MONOMIAL
  []
[]

[Kernels]
  [HeatDiff]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = yttria_thermal_conductivity #use parsed material property, hope it works
    extra_vector_tags = 'ref'
  []
  [HeatTdot]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = yttria_specific_heat_capacity #use parsed material property
    density_name = yttria_density
    extra_vector_tags = 'ref'
  []
  [./HeatSource_JouleHeating]
    type = ADJouleHeatingSource
    variable = temperature
    elec = yttria_potential
    electrical_conductivity = yttria_electrical_conductivity
    extra_vector_tags = 'ref'
  [../]
  [electric_yttria]
    type = ConductivityLaplacian
    variable = yttria_potential
    conductivity_coefficient = yttria_electrical_conductivity
    extra_vector_tags = 'ref'
  []
[]

[AuxKernels]
  [heat_transfer_radiation]
    type = ParsedAux
    variable = heat_transfer_radiation
    boundary = right
    args = 'temperature'
    constant_names = 'boltzmann epsilon temperature_farfield'
    constant_expressions = '5.73e-8 0.85 1300.0'
    function = '-boltzmann*epsilon*(temperature^4-temperature_farfield^4)'
  []
  [microapp_potential]
    type = ParsedAux
    variable = microapp_potential
    args = yttria_potential
    function = 'yttria_potential*1e9' #convert from V to nV
  []
  [E_x]
    type = VariableGradientComponent
    variable = E_x
    gradient_variable = yttria_potential
    component = x
  []
  [E_y]
    type = VariableGradientComponent
    variable = E_y
    gradient_variable = yttria_potential
    component = y
  []
  [microapp_current_density]
    type = ParsedAux
    variable = microapp_current_density
    args = 'sigma_aeh E_y'
    function = '-1.0*sigma_aeh*E_y'
  []
[]

[BCs]
  [external_surface]
    type = CoupledVarNeumannBC
    boundary = right
    variable = temperature
    v = heat_transfer_radiation
  []
  [internal_surface]
    type = FunctionDirichletBC
    boundary = left
    variable = temperature
    function = '${initial_temperature} + 50.0/60.0*t'#'300.0 + 100.0/60.*t' # + 0.50*t/60.0'  #'3 + 100.0/60.*t' #stand-in for the 100C/min heating rate
  []
  [electric_top]
    type = FunctionDirichletBC
    variable = yttria_potential
    boundary = top
    function = '0.05+1.0e-6*t'
  []
  [electric_bottom]
    type = DirichletBC
    variable = yttria_potential
    boundary = bottom
    value = 0.01
  []
[]

[Materials]
  [yttria_thermal_conductivity]
    type = ADParsedMaterial
    # args = 'temperature'
    # function = '3214.46 / (temperature - 147.73)' #in W/(m-K) #Given from Larry's curve fitting, data from Klein and Croft, JAP, v. 38, p. 1603 and UC report "For Computer Heat Conduction Calculations - A compilation of thermal properties data" by A.L. Edwards, UCRL-50589 (1969)
    args = 'thermal_conductivity_aeh'
    function = 'thermal_conductivity_aeh' #in W/(m-K) directly, for now
    f_name = 'yttria_thermal_conductivity'
    output_properties = yttria_thermal_conductivity
    outputs = 'csv exodus'
  []
  [yttria_specific_heat_capacity]
    type = ADParsedMaterial
    f_name = yttria_specific_heat_capacity
    args = 'specific_heat_capacity_va'
    function = 'specific_heat_capacity_va' #in J/(K-kg)
    output_properties = yttria_specific_heat_capacity
    outputs = 'csv exodus'
  [../]
  [./yttria_density]
    type = ADParsedMaterial
    f_name = 'yttria_density'
    args = 'density_va'
    function = 'density_va'
    output_properties = yttria_density
    outputs = 'csv exodus'
  []

  [yttria_electrical_conductivity]
    type = ADParsedMaterial
    args = 'sigma_aeh'
    function = 'sigma_aeh*1.602e8' #converts to units of J/(V^2-m-s)
    f_name = 'yttria_electrical_conductivity'
    output_properties = yttria_electrical_conductivity
    outputs = 'exodus csv'
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  automatic_scaling = true
  compute_scaling_once = false

  # petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  # petsc_options_value = '  asm         101              preonly         ilu        2'
  # petsc_options = '-snes_converged_reason -ksp_converged_reason -options_left -ksp_monitor_singular_value'
  petsc_options_iname = '-ksp_max_it -ksp_gmres_restart -pc_type -snes_max_funcs -sub_pc_factor_levels'
  petsc_options_value = ' 100         100                asm      1000000         1'

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  l_tol = 1e-4
  nl_max_its = 20
  l_max_its = 50
  dtmin = 1.0e-8
  end_time = 480 #8 minutes, enough to ramp BC past 1600K
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 10
    optimal_iterations = 8
    iteration_window = 2
  []
[]

[Postprocessors]
  [temperature]
    type = AverageNodalVariableValue
    variable = temperature
  []
  [yttria_thermal_conductivity]
    type = ElementAverageValue
    variable = yttria_thermal_conductivity
  []
  [passed_in_thermal_conductivity]
    type = ElementAverageValue
    variable = thermal_conductivity_aeh
  []
  [yttria_specific_heat_capacity]
    type = ElementAverageValue
    variable = yttria_specific_heat_capacity
  []
  [passed_in_heat_capacity]
    type = ElementAverageValue
    variable = specific_heat_capacity_va
  []
  [yttria_density]
    type = ElementAverageValue
    variable = yttria_density
  []
  [passed_in_density]
    type = ElementAverageValue
    variable = density_va
  []

  [yttria_sigma]
    type = ElementAverageValue
    variable = yttria_electrical_conductivity
  []
  [passed_in_sigma]
    type = ElementAverageValue
    variable = sigma_aeh
  []
[]

[MultiApps]
  [micro]
    type = CentroidMultiApp # lauches one in the middle of each element so don't need to give positions
      #can specify the number of procs
    max_procs_per_app = 1 #paolo recommends starting here
    app_type = FreyaApp
    input_files = micro_yttria_thermoelectrical_demo.i
    sub_cycling = true
    execute_on = TIMESTEP_BEGIN
  []
[]

[Transfers]
  [keff_from_sub]
    type = MultiAppPostprocessorInterpolationTransfer
    direction = from_multiapp
    multi_app = micro
    variable = thermal_conductivity_aeh
    power = 2 #2 is the default value, tutorial uses 1
    postprocessor = k_AEH_average
  []
  [cpeff_from_sub]
    type = MultiAppPostprocessorInterpolationTransfer
    direction = from_multiapp
    multi_app = micro
    variable = specific_heat_capacity_va
    power = 2 #2 is the default value, tutorial uses 1
    postprocessor = cp_eff
  []
  [density_eff_from_sub]
    type = MultiAppPostprocessorInterpolationTransfer
    direction = from_multiapp
    multi_app = micro
    variable = density_va
    power = 2 #2 is the default value, tutorial uses 1
    postprocessor = density_eff
  []
  [temperature_to_sub]
    type = MultiAppVariableValueSampleTransfer
    direction = to_multiapp
    multi_app = micro
    source_variable = temperature
    variable = temperature_in
  []
  [temperaturepp_to_sub]
   type = MultiAppVariableValueSamplePostprocessorTransfer
    direction = to_multiapp
    multi_app = micro
    source_variable = temperature
    postprocessor = center_temperature
  []

  [sigma_aeh_eff_from_sub]
    type = MultiAppPostprocessorInterpolationTransfer
    direction = from_multiapp
    multi_app = micro
    variable = sigma_aeh
    power = 2 #2 is the default value, tutorial uses 1
    postprocessor = sigma_AEH_average
  []
  [micro_potential_pp_to_sub]
   type = MultiAppVariableValueSamplePostprocessorTransfer
    direction = to_multiapp
    multi_app = micro
    source_variable = microapp_potential
    postprocessor = potential_in
  []
  [micro_current_density_pp_to_sub]
   type = MultiAppVariableValueSamplePostprocessorTransfer
    direction = to_multiapp
    multi_app = micro
    source_variable = microapp_current_density
    postprocessor = current_density_in
  []
[]


[Outputs]
  csv = true
  exodus = true
  perf_graph = true
[]
