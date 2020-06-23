# Cincotti Sample I SPS System Electrothermal Example
# Configuration: Two stainless steel electrodes (with cooling channels) with two
#                large spacers in-between. RZ, axisymmetric. Reproduces Figures
#                18(a), 18(b), and 19 in Cincotti reference (below)
#
# BCs:
#    Potential:
#       V (top electrode, top surface) --> Neumann condition specifiying potential based on applied RMS Current and cross-sectional electrode area (see elec_top BC below)
#       V (bottom electrode, bottom surface) = 0 V
#       V (elsewhere) --> natural boundary conditions (no current external to circuit)
#    Temperature:
#       T (top electrode, top surface) = 300 K
#       T (bottom electrode, bottom surface) = 300 K
#       T (right side) --> simple radiative BC into black body at 300 K
#       T (water channel) --> simple convective BC into "water" with heat transfer coefficient parameter from Cincotti and temperature of 293 K
#       T (elsewhere) --> natural boundary conditions
# Interface Conditions:
#       V (SS-G upper and G-SS lower interface) --> ElectrostaticContactCondition
#       T (SS-G upper and G-SS lower interface) --> ThermalContactCondition
# Initial Conditions:
#       V = default (0 V)
#       T = 300 K
# Applied Mechanical Load: 50 kN
#
# Reference: Cincotti et al, DOI 10.1002/aic.11102

[Mesh]
  [./import_mesh]
    type = FileMeshGenerator
    file = spsdie_table1model1_2d.e
  [../]
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
  [./electric_field_r]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./electric_field_z]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./current_density]
    family = NEDELEC_ONE
    order = FIRST
  [../]
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
    specific_heat = heat_capacity
    block = graphite
  [../]
  [./HeatSource_graphite]
    type = ADJouleHeatingSource
    variable = temperature_graphite
    elec = potential_graphite
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
    specific_heat = heat_capacity
    block = stainless_steel
  [../]
  [./HeatSource_stainless_steel]
    type = ADJouleHeatingSource
    variable = temperature_stainless_steel
    elec = potential_stainless_steel
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

[AuxKernels]
  [./electrostatic_calculation_r_graphite]
    type = PotentialToFieldAux
    gradient_variable = potential_graphite
    variable = electric_field_r
    sign = negative
    component = x
    block = graphite
  [../]
  [./electrostatic_calculation_z_graphite]
    type = PotentialToFieldAux
    gradient_variable = potential_graphite
    variable = electric_field_z
    sign = negative
    component = y
    block = graphite
  [../]
  [./electrostatic_calculation_r_stainless_steel]
    type = PotentialToFieldAux
    gradient_variable = potential_stainless_steel
    variable = electric_field_r
    sign = negative
    component = x
    block = stainless_steel
  [../]
  [./electrostatic_calculation_z_stainless_steel]
    type = PotentialToFieldAux
    gradient_variable = potential_stainless_steel
    variable = electric_field_z
    sign = negative
    component = y
    block = stainless_steel
  [../]
  [./current_density_graphite]
    type = ADCurrentDensity
    variable = current_density
    potential = potential_graphite
    block = graphite
  [../]
  [./current_density_stainless_steel]
    type = ADCurrentDensity
    variable = current_density
    potential = potential_stainless_steel
    block = stainless_steel
  [../]
[]

[BCs]
  [./external_surface_stainless]
    type = ADCoupledSimpleRadiativeHeatFluxBC
    boundary = right_die_stainless_steel
    variable = temperature_stainless_steel
    T_infinity = T_infinity
    emissivity = 0.4
  [../]
  [./external_surface_graphite]
    type = ADCoupledSimpleRadiativeHeatFluxBC
    boundary = right_die_graphite
    variable = temperature_graphite
    T_infinity = T_infinity
    emissivity = 0.85
  [../]
  [./water_channel]
    type = CoupledConvectiveHeatFluxBC
    boundary = water_channel
    variable = temperature_stainless_steel
    T_infinity = 293
    htc = 4725
  [../]
  [./elec_top]
    type = ADFunctionNeumannBC
    variable = potential_stainless_steel
    boundary = top_die
    function = '1200 / (pi * 0.00155)' # RMS Current / Cross-sectional Area. Approximately reflects Cincotti et al (DOI: 10.1002/aic.11102) Figure 19
  [../]
  [./elec_bottom]
    type = ADDirichletBC
    variable = potential_stainless_steel
    boundary = bottom_die
    value = 0
  [../]
[]

[InterfaceKernels]
  [./electric_contact_conductance_ssg]
    type = ElectrostaticContactCondition
    variable = potential_stainless_steel
    neighbor_var = potential_graphite
    boundary = ssg_interface
    mean_hardness = graphite_stainless_mean_hardness
    mechanical_pressure = 9947183.943243457 # = 5e4 / (pi * 0.04 * 0.04) (N / m^2)
  [../]
  [./thermal_contact_conductance_calculated_ssg]
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
    mechanical_pressure = 9947183.943243457 # = 5e4 / (pi * 0.04 * 0.04) (N / m^2)
    boundary = ssg_interface
  [../]
  [./electric_contact_conductance_gss]
    type = ElectrostaticContactCondition
    variable = potential_graphite
    neighbor_var = potential_stainless_steel
    boundary = gss_interface
    mean_hardness = graphite_stainless_mean_hardness
    mechanical_pressure = 9947183.943243457 # = 5e4 / (pi * 0.04 * 0.04) (N / m^2)
  [../]
  [./thermal_contact_conductance_calculated_gss]
    type = ThermalContactCondition
    variable = temperature_graphite
    neighbor_var = temperature_stainless_steel
    primary_potential = potential_graphite
    secondary_potential = potential_stainless_steel
    primary_thermal_conductivity = thermal_conductivity
    secondary_thermal_conductivity = thermal_conductivity
    primary_electrical_conductivity = electrical_conductivity
    secondary_electrical_conductivity = electrical_conductivity
    mean_hardness = graphite_stainless_mean_hardness
    mechanical_pressure = 9947183.943243457 # = 5e4 / (pi * 0.04 * 0.04) (N / m^2)
    boundary = gss_interface
  [../]
[]

[Materials]
  #graphite
  [./heat_conductor_graphite]
    type = ADGraphiteThermal
    temperature = temperature_graphite
    block = graphite
  [../]
  [./rho_graphite]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = 1750
    block = graphite
  [../]
  [./sigma_graphite]
    type = ADGraphiteElectricalConductivity
    temperature = temperature_graphite
    block = graphite
  [../]

  #stainless_steel
  [./heat_conductor_stainless_steel]
    type = ADStainlessSteelThermal
    temperature = temperature_stainless_steel
    block = stainless_steel
  [../]
  [./rho_stainless_steel]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = 8000
    block = stainless_steel
  [../]
  [./sigma_stainless_steel]
    type = ADStainlessSteelElectricalConductivity
    temperature = temperature_stainless_steel
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
  dt = 1
  end_time = 1200
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
