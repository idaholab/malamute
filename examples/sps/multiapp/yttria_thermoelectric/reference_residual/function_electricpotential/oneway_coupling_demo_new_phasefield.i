#This example uses updated electrochemical phase-field model, which includes
#Y and O vacancies as defect species (intrinsic defects)
#One-way coupling from engineering scale to phase-field
initial_temperature=300

[GlobalParams]
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

  [sigma_aeh]
    initial_condition = 2.0e-10 #in units eV/((nV)^2-s-nm)
    order = FIRST
    family = LAGRANGE
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
[]

[Kernels]
  [HeatDiff_yttria]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = yttria_thermal_conductivity #use parsed material property
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
  [heat_transfer_radiation]
    type = ParsedAux
    variable = heat_transfer_radiation
    boundary = right
    coupled_variables = 'temperature'
    constant_names = 'boltzmann epsilon temperature_farfield'  #published emissivity for graphite is 0.85, but use 0.1 to prevent too much heat loss
    constant_expressions = '5.67e-8 0.1 1600.0' #estimated farfield temperature, to stand in for graphite, in a manner
    expression = '-boltzmann*epsilon*(temperature^4-temperature_farfield^4)'
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
[]

[BCs]
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
    function = 'if(t<20.0, 4.0e-3*t, 0.08)'  #rate roughly from Cincotti, per discussion with Casey
  []
  [electric_bottom]
    type = ADDirichletBC
    variable = electric_potential
    boundary = bottom
    value = 0.0
  []
[]

[Materials]
  [yttria_thermal_conductivity]
    type = ADParsedMaterial
    args = 'temperature'
    function = '3214.46 / (temperature - 147.73)' #in W/(m-K) #Given from Larry's curve fitting, data from Klein and Croft, JAP, v. 38, p. 1603 and UC report "For Computer Heat Conduction Calculations - A compilation of thermal properties data" by A.L. Edwards, UCRL-50589 (1969)
    # args = 'thermal_conductivity_aeh'
    # function = 'thermal_conductivity_aeh' #in W/(m-K) directly, for now
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
  []
  [yttria_density]
    type = ADParsedMaterial
    f_name = 'yttria_density'
    args = 'density_va'
    function = 'density_va'
    output_properties = yttria_density
    outputs = 'csv exodus'
  []
  [electrical_conductivity]
    type = ADParsedMaterial
  #   args = 'sigma_aeh'
  #   function = 'sigma_aeh*1.602e-10' #converts to units of J/(V^2-m-s)
    f_name = 'electrical_conductivity'
    output_properties = electrical_conductivity
    outputs = 'exodus csv'
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
  compute_scaling_once = false

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = ' lu       superlu_dist'
  petsc_options = '-snes_converged_reason -ksp_converged_reason'

  nl_forced_its = 1
  nl_rel_tol = 2e-5 #was 1e-10, for temperature only
  nl_abs_tol = 2e-12 #was 1e-10, before that 1e-12
  nl_max_its = 20
  l_max_its = 50
  dtmin = 1.0e-4

  end_time = 2400
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
[]

[MultiApps]
  [micro]
    type = TransientMultiApp
    # type = CentroidMultiApp # lauches one in the middle of each element so don't need to give positions
      #can specify the number of procs
    max_procs_per_app = 1 #paolo recommends starting here
    app_type = MalamuteApp
    positions = '0.0074 0.0058 0' #roughly the center of element 368 in this mesh
    input_files = micro_yttria_thermoelectric_oneway.i
    catch_up = true
    execute_on = TIMESTEP_BEGIN #the default
  []
[]

[Transfers]
  [temperature_to_sub]
    type = MultiAppVariableValueSampleTransfer
    to_multi_app = micro
    source_variable = temperature
    variable = T
  []
  [micro_field_pp_to_sub]
   type = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app = micro
    source_variable = E_y
    postprocessor = Ey_in
  []
[]


[Outputs]
  csv = true
  exodus = true
  perf_graph = true
[]
