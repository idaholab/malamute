# This model includes only heat conduction on a solid block
# of graphite at the engineering scale

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 5
  xmax = 0.01 #1cm
  ymax = 0.01 #1cm
[]

[Problem]
  coord_type = RZ
[]

[Variables]
  [./temperature]
    initial_condition = 300.0
  [../]
[]

[Kernels]
  [./HeatDiff]
    type = HeatConduction
    variable = temperature
    diffusion_coefficient = graphite_thermal_conductivity
  [../]
  [./HeatTdot]
    type = SpecificHeatConductionTimeDerivative
    variable = temperature
    specific_heat = graphite_specific_heat_capacity
    density = graphite_density
  [../]
[]

[BCs]
  [./external_surface]
    type = InfiniteCylinderRadiativeBC
    boundary = right
    variable = temperature
    Tinfinity = 300
    boundary_radius = 0.01
    cylinder_radius = 1
    boundary_emissivity = 0.9
  [../]
  [./top_surface]
    type = FunctionDirichletBC
    boundary = top
    variable = temperature
    function = '300 + 100.0/60.*t' #stand-in for the 100C/min heating rate
  [../]
[]

[Materials]
  [./graphite_thermal_conductivity]
    type = ParsedMaterial
    args = 'temperature'
    function = '1519e-5 * temperature^2 - 8.007e-2 * temperature + 130.2' #in W/(m-K)
    f_name = 'graphite_thermal_conductivity'
    output_properties = graphite_thermal_conductivity
    outputs = 'csv exodus'
  [../]
  [./graphite_specific_heat_capacity]
    type = DerivativeParsedMaterial
    f_name = graphite_specific_heat_capacity
    args = 'temperature'
    function = 'if(temperature<1204, 3.852e-7 * temperature^3
                    - 1.921e-3 * temperature^2 + 3.318 * temperature + 16.282,
                  0.05878 * temperature + 1931.166)' #in J/(K-kg)
    output_properties = graphite_specific_heat_capacity
    outputs = 'csv exodus'
  [../]
  [./graphite_density]
    type = GenericConstantMaterial
    prop_names = 'graphite_density'
    prop_values = 1.75e3 #in kg/m^3
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
  end_time = 1200
[]

[Postprocessors]
  [./temperature]
    type = AverageNodalVariableValue
    variable = temperature
  [../]
  [./graphite_thermal_conductivity]
    type = ElementAverageValue
    variable = graphite_thermal_conductivity
  [../]
  [./graphite_specific_heat_capacity]
    type = ElementAverageValue
    variable = graphite_specific_heat_capacity
  [../]
[]


[Outputs]
  csv = true
  exodus = true
  perf_graph = true
[]
