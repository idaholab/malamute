# Cincotti Sample I SPS System Electrothermal Example
# Configuration: Two stainless steel electrodes (with cooling channels) with two
#                large spacers in-between. RZ, axisymmetric. Reproduces Figures
#                18(a), 18(b), and 19 in Cincotti reference (below)
#
# BCs:
#    Potential:
#       V (top electrode, top surface) --> Neumann condition specifiying potential
#                                          based on applied RMS Current (1200 A)
#                                          and cross-sectional electrode area (see
#                                          elec_top BC below). Current turned off
#                                          at 1200 s.
#       V (bottom electrode, bottom surface) = 0 V
#       V (elsewhere) --> natural boundary conditions (no current external to circuit)
#    Temperature:
#       T (top electrode, top surface) = 293 K
#       T (bottom electrode, bottom surface) = 293 K
#       T (right side) --> simple radiative BC into black body at 293 K
#       T (water channel) --> simple convective BC into "water" with heat transfer
#                             coefficient parameter from Cincotti and temperature of 293 K
#       T (elsewhere) --> natural boundary conditions
# Interface Conditions:
#       V (SS-G upper and G-SS lower interface) --> ElectrostaticContactCondition
#       T (SS-G upper and G-SS lower interface) --> ThermalContactCondition
# Initial Conditions:
#       V = default (0 V)
#       T = 293 K
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
    initial_condition = 293.0
    block = graphite
  [../]
  [./temperature_stainless_steel]
    initial_condition = 293.0
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
    initial_condition = 293.0
  [../]
  [./heatflux_graphite_r]
    family = MONOMIAL
    order = CONSTANT
    block = graphite
  [../]
  [./heatflux_graphite_z]
    family = MONOMIAL
    order = CONSTANT
    block = graphite
  [../]
  [./heatflux_stainless_steel_r]
    family = MONOMIAL
    order = CONSTANT
    block = stainless_steel
  [../]
  [./heatflux_stainless_steel_z]
    family = MONOMIAL
    order = CONSTANT
    block = stainless_steel
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
  [./heat_flux_graphite_r]
    type = DiffusionFluxAux
    diffusivity = nonad_thermal_conductivity
    diffusion_variable = temperature_graphite
    variable = heatflux_graphite_r
    component = x
    block = graphite
  [../]
  [./heat_flux_graphite_z]
    type = DiffusionFluxAux
    diffusivity = nonad_thermal_conductivity
    diffusion_variable = temperature_graphite
    variable = heatflux_graphite_z
    component = y
    block = graphite
  [../]
  [./heat_flux_stainless_r]
    type = DiffusionFluxAux
    diffusivity = nonad_thermal_conductivity
    diffusion_variable = temperature_stainless_steel
    variable = heatflux_stainless_steel_r
    block = stainless_steel
    component = x
  [../]
  [./heat_flux_stainless_z]
    type = DiffusionFluxAux
    diffusivity = nonad_thermal_conductivity
    diffusion_variable = temperature_stainless_steel
    variable = heatflux_stainless_steel_z
    block = stainless_steel
    component = y
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
  [./temp_top]
    type = ADDirichletBC
    variable = temperature_stainless_steel
    boundary = top_die
    value = 293
  [../]
  [./temp_bottom]
    type = ADDirichletBC
    variable = temperature_stainless_steel
    boundary = bottom_die
    value = 293
  [../]
  [./elec_top]
    type = ADFunctionNeumannBC
    variable = potential_stainless_steel
    boundary = top_die
    function = 'if(t < 43, (1200 / (pi * 0.00155))*((0.017703/0.75549)*t), if(t > 1200, 0, 1200 / (pi * 0.00155)))' # RMS Current / Cross-sectional Area. Ramping for t < 43s approximately reflects Cincotti et al (DOI: 10.1002/aic.11102) Figure 18(b)
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
    mechanical_pressure = mechanical_pressure_func
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
    mechanical_pressure = mechanical_pressure_func
    boundary = ssg_interface
  [../]
  [./electric_contact_conductance_gss]
    type = ElectrostaticContactCondition
    variable = potential_graphite
    neighbor_var = potential_stainless_steel
    boundary = gss_interface
    mean_hardness = graphite_stainless_mean_hardness
    mechanical_pressure = mechanical_pressure_func
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
    mechanical_pressure = mechanical_pressure_func
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

  # Material property converter for DiffusionFluxAux object
  [./converter]
    type = MaterialConverter
    ad_props_in = thermal_conductivity
    reg_props_out = nonad_thermal_conductivity
  [../]
[]

[Functions]
  [./mechanical_pressure_func]
    type = ParsedFunction
    vars = 'radius force'
    vals = '0.04 50' # 'm kN'
    value = 'force * 1e3 / (pi * radius^2)' # (N / m^2)
  [../]
[]

# Tracking data locations specified in Cincotti paper
# [Postprocessors]
#   [./temp_tracking]
#     type = PointValue
#     variable = temperature_graphite
#     point = '0 0.28 0'
#   [../]
#   [./potential_tracking]
#     type = PointValue
#     variable = potential_stainless_steel
#     point = '0.027 0.504 0'
#   [../]
# []

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
  end_time = 3600
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
