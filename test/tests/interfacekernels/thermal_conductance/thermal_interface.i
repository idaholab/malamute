[Mesh]
  file = thermal_interface_regular_mesh.e
[]

[Problem]
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
    type = HeatConduction
    variable = temperature_graphite
    block = graphite
  [../]
  [./HeatTdot_graphite]
    type = HeatConductionTimeDerivative
    variable = temperature_graphite
    block = graphite
  [../]
  [./HeatSource_graphite]
    type = JouleHeatingSource
    variable = temperature_graphite
    elec = potential_graphite
    electrical_conductivity = electrical_conductivity
    block = graphite
  [../]

  [./HeatDiff_stainless_steel]
    type = HeatConduction
    variable = temperature_stainless_steel
    block = stainless_steel
  [../]
  [./HeatTdot_stainless_steel]
    type = HeatConductionTimeDerivative
    variable = temperature_stainless_steel
    block = stainless_steel
  [../]
  [./HeatSource_stainless_steel]
    type = JouleHeatingSource
    variable = temperature_stainless_steel
    elec = potential_stainless_steel
    electrical_conductivity = electrical_conductivity
    block = stainless_steel
  [../]

  [./electric_graphite]
    type = ConductivityLaplacian
    variable = potential_graphite
    conductivity_coefficient = electrical_conductivity
    block = graphite
  [../]
  [./electric_stainless_steel]
    type = ConductivityLaplacian
    variable = potential_stainless_steel
    conductivity_coefficient = electrical_conductivity
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
    type = DirichletBC
    variable = potential_stainless_steel
    boundary = top_die
    value = 0.68  # Better reflects Cincotti et al (DOI: 10.1002/aic.11102) Figure 19
  [../]
  [./elec_bottom]
    type = DirichletBC
    variable = potential_stainless_steel
    boundary = bottom_die
    value = 0
  [../]
[]

[InterfaceKernels]
  [./thermal_contact_conductance]
    type = ThermalContactCondition
    variable = temperature_stainless_steel
    neighbor_var = temperature_graphite
    master_potential = potential_stainless_steel
    neighbor_potential = potential_graphite
    master_conductivity = thermal_conductivity
    neighbor_conductivity = thermal_conductivity
    user_electrical_contact_conductance = 2.5e5 # as described in Cincotti et al (DOI: 10.1002/aic.11102)
    user_thermal_contact_conductance = 7 # also from Cincotti et al
    boundary = ssg_interface
  [../]
  [./electric_contact_resistance]
    type = ElectrostaticContactResistance
    variable = potential_stainless_steel
    neighbor_var = potential_graphite
    boundary = ssg_interface
    electrical_contact_resistance = 2.5e5 # as described in Cincotti et al (DOI: 10.1002/aic.11102)
  [../]
[]

[Materials]
  #graphite
  [./heat_conductor_graphite]
    type = HeatConductionMaterial
    thermal_conductivity = 630
    specific_heat = 60
    block = graphite
  [../]
  [./rho_graphite]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 1.75e3
    block = graphite
  [../]
  [./sigma_graphite]
    type = ElectricalConductivity
    temperature = temperature_graphite
    reference_temperature = 293.0
    reference_resistivity = 3.0e-3
    temperature_coefficient = 0 # makes conductivity constant
    block = graphite
  [../]

  #stainless_steel
  [./heat_conductor_stainless_steel]
    type = HeatConductionMaterial
    thermal_conductivity = 17
    specific_heat = 502
    block = stainless_steel
  [../]
  [./rho_stainless_steel]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 8e3
    block = stainless_steel
  [../]
  [./sigma_stainless_steel]
    type = ElectricalConductivity
    temperature = temperature_stainless_steel
    reference_temperature = 293.0
    reference_resistivity = 7e-7
    temperature_coefficient = 0 # makes conductivity constant
    block = stainless_steel
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
