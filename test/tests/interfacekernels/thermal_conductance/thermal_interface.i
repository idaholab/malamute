# Input file block to generate this mesh can be found in thermal_interface_mesh.i
[Mesh]
  file = thermal_interface_regular_mesh.e
  coord_type = RZ
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
  [./potential_graphite]
    block = graphite
  [../]
  [./potential_stainless_steel]
    block = stainless_steel
  [../]
[]

[AuxVariables]
  [./T_infinity]
    initial_condition = 300.0
  [../]
[]

[Kernels]
  [./HeatDiff_graphite]
    type = ADHeatConduction
    variable = temperature_graphite
    block = graphite
  [../]
  [./HeatTdot_graphite]
    type = ADHeatConductionTimeDerivative
    variable = temperature_graphite
    block = graphite
  [../]
  [./HeatSource_graphite]
    type = ADJouleHeatingSource
    variable = temperature_graphite
    elec = potential_graphite
    electrical_conductivity = electrical_conductivity
    block = graphite
  [../]

  [./HeatDiff_stainless_steel]
    type = ADHeatConduction
    variable = temperature_stainless_steel
    block = stainless_steel
  [../]
  [./HeatTdot_stainless_steel]
    type = ADHeatConductionTimeDerivative
    variable = temperature_stainless_steel
    block = stainless_steel
  [../]
  [./HeatSource_stainless_steel]
    type = ADJouleHeatingSource
    variable = temperature_stainless_steel
    elec = potential_stainless_steel
    electrical_conductivity = electrical_conductivity
    block = stainless_steel
  [../]

  [./electric_graphite]
    type = ADMatDiffusion
    variable = potential_graphite
    diffusivity = electrical_conductivity
    block = graphite
  [../]
  [./electric_stainless_steel]
    type = ADMatDiffusion
    variable = potential_stainless_steel
    diffusivity = electrical_conductivity
    block = stainless_steel
  [../]
[]

[BCs]
  [./external_surface_stainless]
    type = ADCoupledSimpleRadiativeHeatFluxBC
    boundary = right_stainless_steel
    variable = temperature_stainless_steel
    T_infinity = T_infinity
    emissivity = 0.85
  [../]
  [./external_surface_graphite]
    type = ADCoupledSimpleRadiativeHeatFluxBC
    boundary = right_graphite
    variable = temperature_graphite
    T_infinity = T_infinity
    emissivity = 0.85
  [../]
  [./elec_top]
    type = ADDirichletBC
    variable = potential_stainless_steel
    boundary = top_die
    value = 0.68  # Better reflects Cincotti et al (DOI: 10.1002/aic.11102) Figure 19
  [../]
  [./elec_bottom]
    type = ADDirichletBC
    variable = potential_stainless_steel
    boundary = bottom_die
    value = 0
  [../]
[]

[InterfaceKernels]
  active = 'thermal_contact_conductance electric_contact_conductance'

  [./thermal_contact_conductance]
    type = ThermalContactCondition
    variable = temperature_stainless_steel
    neighbor_var = temperature_graphite
    primary_potential = potential_stainless_steel
    secondary_potential = potential_graphite
    primary_thermal_conductivity = thermal_conductivity
    secondary_thermal_conductivity = thermal_conductivity
    primary_electrical_conductivity = electrical_conductivity
    secondary_electrical_conductivity = electrical_conductivity
    user_electrical_contact_conductance = 2.5e5 # as described in Cincotti et al (DOI: 10.1002/aic.11102)
    user_thermal_contact_conductance = 7 # also from Cincotti et al
    boundary = ssg_interface
  [../]
  [./electric_contact_conductance]
    type = ElectrostaticContactCondition
    variable = potential_stainless_steel
    neighbor_var = potential_graphite
    primary_conductivity = electrical_conductivity
    secondary_conductivity = electrical_conductivity
    boundary = ssg_interface
    user_electrical_contact_conductance = 2.5e5 # as described in Cincotti et al (DOI: 10.1002/aic.11102)
  [../]

  [./thermal_contact_conductance_calculated]
    type = ThermalContactCondition
    variable = temperature_stainless_steel
    neighbor_var = temperature_graphite
    primary_potential = potential_stainless_steel
    secondary_potential = potential_graphite
    primary_thermal_conductivity = thermal_conductivity
    secondary_thermal_conductivity = thermal_conductivity
    primary_electrical_conductivity = electrical_conductivity
    secondary_electrical_conductivity = electrical_conductivity
    mean_hardness = graphite_stainless_mean_hardness
    mechanical_pressure = 8.52842e10 # resulting in electrical contact conductance = ~1.4715e5, thermal contact conductance = ~3.44689e7
    boundary = ssg_interface
  [../]
[]

[Materials]
  active = 'heat_conductor_graphite rho_graphite sigma_graphite heat_conductor_stainless_steel rho_stainless_steel sigma_stainless_steel'

  #graphite
  [./heat_conductor_graphite]
    type = ADHeatConductionMaterial
    thermal_conductivity = 630
    specific_heat = 60
    block = graphite
  [../]
  [./rho_graphite]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = 1.75e3
    block = graphite
  [../]
  [./sigma_graphite]
    type = ADElectricalConductivity
    temperature = temperature_graphite
    reference_temperature = 293.0
    reference_resistivity = 3.0e-3
    temperature_coefficient = 0 # makes conductivity constant
    block = graphite
  [../]

  #stainless_steel
  [./heat_conductor_stainless_steel]
    type = ADHeatConductionMaterial
    thermal_conductivity = 17
    specific_heat = 502
    block = stainless_steel
  [../]
  [./rho_stainless_steel]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = 8e3
    block = stainless_steel
  [../]
  [./sigma_stainless_steel]
    type = ADElectricalConductivity
    temperature = temperature_stainless_steel
    reference_temperature = 293.0
    reference_resistivity = 7e-7
    temperature_coefficient = 0 # makes conductivity constant
    block = stainless_steel
  [../]

  # harmonic mean of graphite and stainless steel hardness
  [./mean_hardness]
    type = GraphiteStainlessMeanHardness
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  dt = 0.1
  end_time = 100
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
