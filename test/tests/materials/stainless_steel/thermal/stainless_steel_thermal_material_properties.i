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
#      498.8            523.5                   516.7          523.4
#
# Heat Capacity (J/kg-K):
#        Experimental Data Point                Simulation Result
#  Temperature(K)   Heat Capacity           Temperature(K)  Heat Capacity
#      643.4             19.84                  641.7           19.62

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
    initial_condition = 350.0
  [../]
[]

[Kernels]
  [./HeatDiff]
    type = HeatConduction
    variable = temperature
    diffusion_coefficient = thermal_conductivity
  [../]
  [./HeatTdot]
    type = HeatConductionTimeDerivative
    variable = temperature
    specific_heat = heat_capacity
    density_name = stainless_steel_density
  [../]
[]

[BCs]
  [./top_surface]
    type = FunctionDirichletBC
    boundary = top
    variable = temperature
    function = '350 + 100.0/60.*t' #stand-in for the 100C/min heating rate
  [../]
[]

[Materials]
  [./stainless_steel_thermal]
    type = StainlessSteelThermal
    temperature = temperature
    output_properties = all
  [../]
  [./stainless_steel_density]
    type = GenericConstantMaterial
    prop_names = 'stainless_steel_density'
    prop_values = 8.0e3 #in kg/m^3 from Cincotti et al 2007, Table 2, doi:10.1002/aic
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
  end_time = 400
[]

[Postprocessors]
  [./max_temperature]
    type = NodalExtremeValue
    variable = temperature
    value_type = max
  [../]
  [./max_thermal_conductivity]
    type = ElementExtremeMaterialProperty
    mat_prop = thermal_conductivity
    value_type = max
  [../]
  [./max_heat_capacity]
    type = ElementExtremeMaterialProperty
    mat_prop = heat_capacity
    value_type = max
  [../]
[]


[Outputs]
  csv = true
  perf_graph = true
[]
