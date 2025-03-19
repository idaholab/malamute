initial_temperature = 1350

[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = false
  order = SECOND
[]

[Mesh]
  coord_type = RZ
  second_order = true
  [yttria_block]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 25
    ny = 20
    xmax = 0.01 #10mm
    ymax = 0.008 #8mm
    elem_type = QUAD8
  []
  [centerpoint_node]
    type = BoundingBoxNodeSetGenerator
    bottom_left = '0.0 0.0039 0.0'
    top_right = '0.0001 0.0041 0.0'
    new_boundary = centerpoint_block
    input = yttria_block
  []
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

  [sigma_aeh]
    initial_condition = 2.0e-10 #in units eV/((nV)^2-s-nm)
  []
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
  [current_density_J]
    family = NEDELEC_ONE
    order = FIRST
  []
  [microapp_current_density]
    order = FIRST
    family = MONOMIAL
  []
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [yttria]
        strain = FINITE
        add_variables = true
        use_automatic_differentiation = true
        generate_output = 'strain_xx strain_xy strain_yy strain_zz stress_xx stress_xy stress_yy stress_zz'
        extra_vector_tags = 'ref'
        eigenstrain_names = 'yttria_thermal_expansion'
      []
    []
  []
[]

[Kernels]
  [HeatDiff_yttria]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = yttria_thermal_conductivity #use parsed material property, hope it works
    extra_vector_tags = 'ref'
  []
  [HeatTdot_yttria]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = yttria_specific_heat_capacity #use parsed material property
    density_name = yttria_density
    extra_vector_tags = 'ref'
  []
  [JouleHeating_yttria]
    type = ADJouleHeatingSource
    variable = temperature
    elec = electric_potential
    electrical_conductivity = electrical_conductivity
    use_displaced_mesh = true
    extra_vector_tags = 'ref'
  []
  [electric_yttria]
    type = ADMatDiffusion
    variable = electric_potential
    diffusivity = electrical_conductivity
    use_displaced_mesh = true
    extra_vector_tags = 'ref'
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
    boundary = right
    coupled_variables = 'temperature'
    constant_names = 'boltzmann epsilon temperature_farfield' #published emissivity for graphite is 0.85, but use 0.1 to prevent too much heat loss
    constant_expressions = '5.67e-8 0.1 1000.0' #estimated farfield temperature, to stand in for graphite, in a manner
    expression = '-boltzmann*epsilon*(temperature^4-temperature_farfield^4)'
  []
  [microapp_potential]
    type = ParsedAux
    variable = microapp_potential
    coupled_variables = electric_potential
    expression = 'electric_potential*1e9' #convert from V to nV
  []
  [E_x]
    type = VariableGradientComponent
    variable = E_x
    gradient_variable = electric_potential
    component = x
  []
  [E_y]
    type = VariableGradientComponent
    variable = E_y
    gradient_variable = electric_potential
    component = y
  []
  [current_density_J]
    type = ADCurrentDensity
    variable = current_density_J
    potential = electric_potential
  []
  [microapp_current_density]
    type = ParsedAux
    variable = microapp_current_density
    coupled_variables = 'sigma_aeh E_y' ## Probably needs to be updated to use the current_density_J
    expression = '-1.0*sigma_aeh*E_y'
  []
[]

[BCs]
  [centerline_no_dispx]
    type = ADDirichletBC
    preset = true
    variable = disp_x
    value = 0
    boundary = 'left'
  []
  [fixed_in_y]
    type = ADDirichletBC
    preset = true
    variable = disp_y
    value = 0
    boundary = 'centerpoint_block' #centerpoint_inner_die_wall
  []
  [bottom_pressure_ydirection]
    type = ADPressure
    variable = disp_y
    boundary = 'bottom'
    function = 'if(t<1.0, (20.7e6/1.0)*t, 20.7e6)'
  []
  [top_pressure_ydirection]
    type = ADPressure
    variable = disp_y
    boundary = 'top'
    function = 'if(t<1.0, (20.7e6/1.0)*t, 20.7e6)'
  []

  [external_surface]
    type = CoupledVarNeumannBC
    boundary = right
    variable = temperature
    v = heat_transfer_radiation
  []
  # [internal_surface_temperature] #might be needed since yttia conductivity is low
  #   type = FunctionDirichletBC
  #   boundary = left
  #   variable = temperature
  #   function = '${initial_temperature} + 50.0/60.0*t' #stand-in for a 50C/min heating rate
  # []

  [electric_top]
    type = ADFunctionDirichletBC
    variable = electric_potential
    boundary = top
    function = 'if(t<1.0,0.0, if(t<20.0, 4.0e-3*t, 0.08))' #rate roughly from Cincotti, per discussion with Casey
  []
  [electric_bottom]
    type = ADDirichletBC
    variable = electric_potential
    boundary = bottom
    value = 0.0
  []
[]

[Materials]
  [yttria_elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    # youngs_modulus = 1.16e11 #in Pa for fully dense part
    youngs_modulus = 1.38e10 #in Pa assuming 62% initial density and theoretical coeff. from Phani and Niyogi (1987)
    poissons_ratio = 0.36
  []
  [yttria_elastic_stress]
    type = ADComputeFiniteStrainElasticStress
  []
  # [yttria_stress]
  #   type = ADComputeMultipleInelasticStress
  #   inelastic_models = yttria_creep_model
  # []
  # # [yttria_creep_model]
  # #   type = ADPowerLawCreepStressUpdate
  # #   coefficient = 3.75e-7 # from Al's work
  # #   n_exponent = 0.714 # from Al's work
  # #   activation_energy = 0.0
  # #   use_substepping = INCREMENT_BASED
  # #   absolute_tolerance = 5e-9
  # # []
  [yttria_thermal_expansion]
    type = ADComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 9.3e-6 # from https://doi.org/10.1111/j.1151-2916.1957.tb12619.x
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
    outputs = 'exodus'
  []
  [yttria_specific_heat_capacity]
    type = ADParsedMaterial
    property_name = yttria_specific_heat_capacity
    coupled_variables = 'specific_heat_capacity_va'
    expression = 'specific_heat_capacity_va' #in J/(K-kg)
    output_properties = yttria_specific_heat_capacity
    outputs = 'exodus'
  []
  [yttria_density]
    type = ADParsedMaterial
    property_name = 'yttria_density'
    coupled_variables = 'density_va'
    expression = 'density_va'
    output_properties = yttria_density
    outputs = 'exodus'
  []
  [electrical_conductivity]
    type = ADParsedMaterial
    #   coupled_variables = 'sigma_aeh'
    #   expression = 'sigma_aeh*1.602e8' #converts to units of J/(V^2-m-s)
    property_name = 'electrical_conductivity'
    output_properties = electrical_conductivity
    outputs = 'exodus'
    # type = ADDerivativeParsedMaterial
    # property_name = electrical_conductivity
    coupled_variables = 'temperature'
    constant_names = 'Q_elec  kB            prefactor_solid  initial_porosity'
    constant_expressions = '1.61    8.617343e-5        1.25e-4           0.38'
    expression = '(1-initial_porosity) * prefactor_solid * exp(-Q_elec/kB/temperature) * 1.602e8' # in eV/(nV^2 s nm) per chat with Larry, last term converts to units of J/(V^2-m-s)
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  automatic_scaling = true
  line_search = 'none'
  compute_scaling_once = false

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

  end_time = 360 #6 minutes, enough to ramp BC to 1600K #1200 #represents 20 minutes
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.05
    optimal_iterations = 8
    iteration_window = 2
  []
  # num_steps = 4
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
  [yttria_specific_heat_capacity]
    type = ElementAverageValue
    variable = yttria_specific_heat_capacity
  []
  [yttria_density]
    type = ElementAverageValue
    variable = yttria_density
  []
  [yttria_sigma]
    type = ElementAverageValue
    variable = electrical_conductivity
  []

  ### The following are useful for debugging, but are mesh dependent via the elementid
  [temperature_368]
    type = ElementalVariableValue
    variable = temperature
    elementid = 368
  []
  [yttria_thermal_conductivity_368]
    type = ElementalVariableValue
    elementid = 368
    variable = yttria_thermal_conductivity
  []
  [yttria_specific_heat_capacity_368]
    type = ElementalVariableValue
    elementid = 368
    variable = yttria_specific_heat_capacity
  []
  [yttria_electrical_conductivity_368]
    type = ElementalVariableValue
    elementid = 368
    variable = electrical_conductivity
  []
  [yttria_microapp_potential]
    type = ElementalVariableValue
    elementid = 368
    variable = microapp_potential
  []
  [yttria_grad_potential]
    type = ElementalVariableValue
    variable = E_y
    elementid = 368
  []
  [microapp_current_density]
    type = ElementalVariableValue
    variable = microapp_current_density
    elementid = 368
  []
[]

[MultiApps]
  [micro]
    type = TransientMultiApp
    # type = CentroidMultiApp # lauches one in the middle of each element so don't need to give positions
    #can specify the number of procs
    max_procs_per_app = 1 #paolo recommends starting here
    app_type = MalamuteApp
    positions = '0.0074 0.0058 0' #roughly the center of element 368 in this mesh
    input_files = micro_yttria_thermoelectrical_aehproperties_refres.i
    catch_up = true
    execute_on = TIMESTEP_BEGIN #the default
  []
[]

[Transfers]
  [temperature_to_sub]
    type = MultiAppVariableValueSampleTransfer
    to_multi_app = micro
    source_variable = temperature
    variable = temperature_in
  []
  [temperaturepp_to_sub]
    type = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app = micro
    source_variable = temperature
    postprocessor = center_temperature
  []

  [micro_potential_pp_to_sub]
    type = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app = micro
    source_variable = microapp_potential
    postprocessor = potential_in
  []
  [micro_current_density_pp_to_sub]
    type = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app = micro
    source_variable = microapp_current_density
    postprocessor = current_density_in
  []
[]

[Outputs]
  csv = true
  exodus = true
  perf_graph = true
[]
