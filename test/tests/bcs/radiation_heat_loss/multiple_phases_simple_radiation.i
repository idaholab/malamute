# This is a simple 3D test of the simplistic radiation heat transfer loss. The
# body to which the heat is lost is considered as a pure blackbody.
# A rectangular prism is set to a uniform temperature, 400K, while the absolute
# temperature of the surrounding assumed blackbody is set to 293K. The emissivity
# is assumed to be 0.95 for 0.4 of the body and 0.07 for the remaining 0.6 of the
# body. A high thermal conductivity is used to obtain a nearly uniform temperature
# through the body needed to match to analytical solution. The heat flux loss
# through the right boundary with this radiative heat transfer boundary condition
# is calculated.
#
# The analytical solution is:
# Q = \sum_i (\alpha_i \epsilon_i * \sigma * (T^4_{body} - T^4_{infinity}))
#   = 0.4 * 0.95 * 5.67e-8 * (400^4 - 293^4) + 0.6 * 0.07 * 5.67e-8 * (400^4 - 293^4)
#   = 436.1953 W

[Mesh]
  type = GeneratedMesh
  dim = 3
  xmax = 0.01
  ymax = 1.0
  zmax = 1.0
  nx = 10
  ny = 5
  nz = 5
[]

[Variables]
  [./temperature]
    initial_condition = 400.0
  [../]
[]

[Kernels]
  [./heat]
    type = HeatConduction
    variable = temperature
  [../]
[]

[BCs]
  [./heatloss]
    type = ADCoupledSimpleRadiativeHeatFluxBC
    boundary = right
    variable = temperature
    T_infinity = '293 293'
    emissivity = '0.95 0.07'
    alpha = '0.4 0.6'
  [../]
  [./insulation]
    type = DirichletBC
    boundary = 'left'
    variable = temperature
    value = 400
  [../]
[]

[Materials]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity'
    prop_values = '1e3'
  [../]
[]

[Executioner]
  type = Steady
  line_search = none
[]

[Postprocessors]
  [./right_temperature]
    type = SideAverageValue
    variable = temperature
    boundary = right
  [../]
  [./right_heatflux]
    type = SideFluxIntegral
    variable = temperature
    boundary = right
    diffusivity = thermal_conductivity
  [../]
[]

[Outputs]
  csv = true
  perf_graph = true
[]
