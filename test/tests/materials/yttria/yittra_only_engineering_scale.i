# This model includes only heat conduction on a solid block
# of yttria at the engineering scale

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 5
  xmax = 0.01 #1cm
  ymax = 0.01 #1cm
  coord_type = RZ
[]

[Variables]
  [temperature]
    initial_condition = 300.0
  []
[]

[Kernels]
  [HeatDiff]
    type = HeatConduction
    variable = temperature
    diffusion_coefficient = yttria_thermal_conductivity
  []
  [HeatTdot]
    type = SpecificHeatConductionTimeDerivative
    variable = temperature
    specific_heat = yttria_specific_heat_capacity
    density = yttria_density
  []
[]

[BCs]
  [external_surface]
    type = InfiniteCylinderRadiativeBC
    boundary = right
    variable = temperature
    Tinfinity = 300
    boundary_radius = 0.01
    cylinder_radius = 1
    boundary_emissivity = 0.9
  []
  [top_surface]
    type = FunctionDirichletBC
    boundary = top
    variable = temperature
    function = '293 + 100.0/60.*t' #stand-in for the 100C/min heating rate
  []
[]

[Materials]
  [yttria_thermal_conductivity]
    type = ParsedMaterial
    coupled_variables = 'temperature'
    expression = '3214.46 / (temperature - 147.73)' #in W/(m-K)
    property_name = 'yttria_thermal_conductivity'
    output_properties = yttria_thermal_conductivity
    outputs = 'exodus'
  []
  [yttria_specific_heat_capacity]
    type = DerivativeParsedMaterial
    property_name = yttria_specific_heat_capacity
    coupled_variables = 'temperature'
    constant_names =        'molar_mass    gtokg'
    constant_expressions =  '225.81         1.0e3' #
    expression = 'if(temperature<1503.7, (3.0183710318246e-19 * temperature^7 - 2.03644357435399e-15 * temperature^6
                              + 5.75283959486472e-12 * temperature^5 - 8.8224198737065e-09 * temperature^4
                              + 7.96030446457309e-06  * temperature^3 - 0.00427362972278911 * temperature^2
                              + 1.30756778141995 * temperature - 61.6301212149735) / molar_mass * gtokg,
                  (0.0089*temperature + 119.59) / molar_mass * gtokg)' #in J/(K-kg)
    output_properties = yttria_specific_heat_capacity
    outputs = 'exodus'
  []
  [yttria_density]
    type = GenericConstantMaterial
    prop_names = 'yttria_density'
    prop_values = 5.01e3 #in kg/m^3, 5.01 g/cm^3
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  automatic_scaling = true

  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         101   preonly   ilu      1'
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  l_tol = 1e-4
  nl_max_its = 20
  l_max_its = 50
  dt = 25
  dtmin = 1.0e-8
  end_time = 1000
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
[]

[Outputs]
  csv = true
  exodus = true
  perf_graph = true
[]
