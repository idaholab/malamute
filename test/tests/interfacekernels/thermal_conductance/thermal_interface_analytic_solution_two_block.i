[Mesh]
  [./line]
    type = GeneratedMeshGenerator
    xmax = 2
    dim = 1
    nx = 400
  [../]
  [./split]
    type = SubdomainBoundingBoxGenerator
    bottom_left = '0 0 0'
    top_right = '1 0 0'
    block_id = 1
    block_name = 'stainless_steel'
    input = line
  [../]
  [./rename_right]
    type = RenameBlockGenerator
    old_block = 0
    new_block = 'graphite'
    input = split
  [../]
  [./interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = rename_right
    primary_block = 'stainless_steel'
    paired_block = 'graphite'
    new_boundary = 'ssg_interface'
  [../]
[]

[Variables]
  [./temperature_graphite]
    initial_condition = 300.0
    block = graphite
  [../]
  [./temperature_stainless_steel]
    initial_condition = 300.0
    block = stainless_steel
  [../]
[]

[AuxVariables]
  [./analytic_potential_graphite]
    block = graphite
  [../]
  [./analytic_potential_stainless_steel]
    block = stainless_steel
  [../]
  [./analytic_temperature_graphite]
    block = graphite
  [../]
  [./analytic_temperature_stainless_steel]
    block = stainless_steel
  [../]
[]

[Kernels]
  [./HeatDiff_graphite]
    type = ADHeatConduction
    variable = temperature_graphite
    block = graphite
  [../]
  [./HeatSource_graphite]
    type = ADJouleHeatingSource
    variable = temperature_graphite
    elec = analytic_potential_graphite
    electrical_conductivity = electrical_conductivity
    block = graphite
  [../]

  [./HeatDiff_stainless_steel]
    type = ADHeatConduction
    variable = temperature_stainless_steel
    block = stainless_steel
  [../]
  [./HeatSource_stainless_steel]
    type = ADJouleHeatingSource
    variable = temperature_stainless_steel
    elec = analytic_potential_stainless_steel
    electrical_conductivity = electrical_conductivity
    block = stainless_steel
  [../]
[]

[AuxKernels]
  [./analytic_potential_function_aux_stainless_steel]
    type = FunctionAux
    function = potential_fxn_stainless_steel
    variable = analytic_potential_stainless_steel
    block = stainless_steel
  [../]
  [./analytic_potential_function_aux_graphite]
    type = FunctionAux
    function = potential_fxn_graphite
    variable = analytic_potential_graphite
    block = graphite
  [../]
  [./analytic_temperature_function_aux_stainless_steel]
    type = FunctionAux
    function = temperature_fxn_stainless_steel
    variable = analytic_temperature_stainless_steel
    block = stainless_steel
  [../]
  [./analytic_temperature_function_aux_graphite]
    type = FunctionAux
    function = temperature_fxn_graphite
    variable = analytic_temperature_graphite
    block = graphite
  [../]
[]

[BCs]
  [./thermal_left]
    type = DirichletBC
    variable = temperature_stainless_steel
    boundary = left
    value = 300
  [../]
  [./thermal_right]
    type = DirichletBC
    variable = temperature_graphite
    boundary = right
    value = 300
  [../]
[]

[InterfaceKernels]
  [./thermal_contact_conductance]
    type = ThermalContactCondition
    variable = temperature_stainless_steel
    neighbor_var = temperature_graphite
    primary_potential = analytic_potential_stainless_steel
    secondary_potential = analytic_potential_graphite
    primary_thermal_conductivity = thermal_conductivity
    secondary_thermal_conductivity = thermal_conductivity
    primary_electrical_conductivity = electrical_conductivity
    secondary_electrical_conductivity = electrical_conductivity
    user_electrical_contact_conductance = 75524 # at 300K with 3 kN/m^2 applied pressure
    user_thermal_contact_conductance = 0.242 # also from Cincotti et al
    boundary = ssg_interface
  [../]
[]

[Materials]
  #graphite
  [./heat_conductor_graphite]
    type = ADGenericConstantMaterial
    prop_names = thermal_conductivity
    prop_values = 100
    block = graphite
  [../]
  [./sigma_graphite]
    type = ADGenericConstantMaterial
    prop_names = electrical_conductivity
    prop_values = 73069.2
    block = graphite
  [../]

  #stainless_steel
  [./heat_conductor_stainless_steel]
    type = ADGenericConstantMaterial
    prop_names = thermal_conductivity
    prop_values = 15
    block = stainless_steel
  [../]
  [./sigma_stainless_steel]
    type = ADGenericConstantMaterial
    prop_names = electrical_conductivity
    prop_values = 1.41867e6
    block = stainless_steel
  [../]
[]

[Functions]
  [./potential_fxn_stainless_steel]
    type = ThermalContactPotentialTestFunc
    domain = stainless_steel
  [../]
  [./potential_fxn_graphite]
    type = ThermalContactPotentialTestFunc
    domain = graphite
  [../]
  [./temperature_fxn_stainless_steel]
    type = ThermalContactTemperatureTestFunc
    domain = stainless_steel
  [../]
  [./temperature_fxn_graphite]
    type = ThermalContactTemperatureTestFunc
    domain = graphite
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
