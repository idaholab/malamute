# This model includes only electrical conduction on a solid block
# of stainless_steel at the engineering scale

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  xmax = 0.01 #1cm
  ymax = 0.01 #1cm
[]

[Problem]
  coord_type = RZ
[]

[Variables]
  [./stainless_steel_potential]
  [../]
[]

[AuxVariables]
  [./temperature]
    initial_condition = 900.0
  [../]
[]

[Kernels]
  [./electric_stainless_steel]
    type = ConductivityLaplacian
    variable = stainless_steel_potential
    conductivity_coefficient = stainless_steel_electrical_conductivity
  [../]
[]

[BCs]
  [./elec_top]
    type = DirichletBC
    variable = stainless_steel_potential
    boundary = top
    value = 10
  [../]
  [./elec_bottom]
    type = DirichletBC
    variable = stainless_steel_potential
    boundary = bottom
    value = 0
  [../]
[]

[Materials]
  [./stainless_steel_electrical_conductivity]
    type = DerivativeParsedMaterial
    f_name = stainless_steel_electrical_conductivity
    args = 'temperature'
    function = '1.575e-15 * temperature^2 - 3.236e-12 * temperature^2
                + 2.724e-9 * temperature + 1.364e-7' #in \Omega/(m)
    output_properties = stainless_steel_electrical_conductivity
    outputs = 'csv exodus'
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Steady
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         101   preonly   ilu      1'
  automatic_scaling = true
[]

[Postprocessors]
  [./temperature]
    type = AverageNodalVariableValue
    variable = temperature
  [../]
  [./stainless_steel_electrical_conductivity]
    type = ElementAverageValue
    variable = stainless_steel_electrical_conductivity
  [../]
  [./stainless_steel_potential]
    type = AverageNodalVariableValue
    variable = stainless_steel_potential
  [../]
[]


[Outputs]
  csv = true
  exodus = true
  perf_graph = true
[]
