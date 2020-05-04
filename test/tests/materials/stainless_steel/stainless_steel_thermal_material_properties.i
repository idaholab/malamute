#This model includes only heat conduction on a solid block
#of graphite at the engineering scale

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 5
  xmax = 0.01 #1cm
  ymax = 0.02 #2cm
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
    diffusion_coefficient = stainless_steel_thermal_conductivity
  [../]
  [./HeatTdot]
    type = SpecificHeatConductionTimeDerivative
    variable = temperature
    specific_heat = stainless_steel_specific_heat_capacity
    density = stainless_steel_density
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
  [./stainless_steel_thermal_conductivity]
    type = ParsedMaterial
    args = 'temperature'
    function = '0.0144 * temperature + 10.55' #in W/(m-K), from Cincotti et al (2007)
    f_name = 'stainless_steel_thermal_conductivity'
    output_properties = stainless_steel_thermal_conductivity
    outputs = 'csv exodus'
  [../]
  [./stainless_steel_specific_heat_capacity]
    type = DerivativeParsedMaterial
    f_name = stainless_steel_specific_heat_capacity
    args = 'temperature'
    function = '2.484e-7 * temperature^3 - 7.321e-4 * temperature^2
                + 0.840 * temperature + 253.7' #in J/(K-kg)
    output_properties = stainless_steel_specific_heat_capacity
    outputs = 'csv exodus'
  [../]
  [./stainless_steel_density]
    type = GenericConstantMaterial
    prop_names = 'stainless_steel_density'
    prop_values = 8.0e3 #in kg/m^3
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
  [./stainless_steel_thermal_conductivity]
    type = ElementAverageValue
    variable = stainless_steel_thermal_conductivity
  [../]
  [./stainless_steel_specific_heat_capacity]
    type = ElementAverageValue
    variable = stainless_steel_specific_heat_capacity
  [../]
[]


[Outputs]
  csv = true
  exodus = true
  perf_graph = true
[]
