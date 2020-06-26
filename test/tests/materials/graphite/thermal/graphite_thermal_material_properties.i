# This model includes only heat conduction on a two element block and is intended
# verify the curve fits from Cincotti et al (2007) AIChE Journal, Vol 53 No 3,
# page 711 Figures 8a and 8c.
#
# Experimental data points which nearly lie on the curve fit are compared to the
# simulation outputs at similar temperatures, below, to verify both the curve
# fits and the material model tested here:
#
# Thermal Conductivity (W/m-K):
#        Experimental Data Point                Simulation Result
#  Temperature(K)   Thermal Conductivity    Temperature(K)  Thermal Conductivity
#      1268.9            53.21                   1250           55.44
#
# Heat Capacity (J/kg-K):
#        Experimental Data Points                Simulation Results
#  Temperature(K)   Heat Capacity           Temperature(K)  Heat Capacity
#      1399.7          1952.25                  1416.7           1953.6
#      3105.5          2114.0                   3166.7           2116.5

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 1
  ny = 2
  xmax = 0.01 #1cm
  ymax = 0.02 #2cm
[]

[Problem]
  coord_type = RZ
[]

[Variables]
  [./temperature]
    initial_condition = 500.0
  [../]
[]

[Kernels]
  [./HeatDiff]
    type = ADHeatConduction
    variable = temperature
    diffusion_coefficient = thermal_conductivity
  [../]
  [./HeatTdot]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = heat_capacity
    density_name = graphite_density
  [../]
[]

[BCs]
  [./top_surface]
    type = ADFunctionDirichletBC
    boundary = top
    variable = temperature
    function = '500 + 200.0/60.*t' #stand-in for the 200C/min heating rate
  [../]
[]

[Materials]
  [./graphite_thermal]
    type = ADGraphiteThermal
    temperature = temperature
    output_properties = all
  [../]
  [./graphite_density]
    type = ADGenericConstantMaterial
    prop_names = 'graphite_density'
    prop_values = 1.750e3 #in kg/m^3 from Cincotti et al 2007, Table 2, doi:10.1002/aic
  [../]
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  automatic_scaling = true

  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm          ilu         1'
  nl_max_its = 20
  l_max_its = 50
  dt = 25
  dtmin = 1.0e-8
  end_time = 800
[]

[Postprocessors]
  [./max_temperature]
    type = NodalExtremeValue
    variable = temperature
    value_type = max
  [../]
  [./max_thermal_conductivity]
    type = ADElementExtremeMaterialProperty
    mat_prop = thermal_conductivity
    value_type = max
  [../]
  [./max_heat_capacity]
    type = ADElementExtremeMaterialProperty
    mat_prop = heat_capacity
    value_type = max
  [../]
[]

[Outputs]
  csv = true
  perf_graph = true
[]
