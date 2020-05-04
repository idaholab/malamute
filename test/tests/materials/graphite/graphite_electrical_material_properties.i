# This model includes only electrical conduction on a solid block
# of graphite at the engineering scale

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
  [./graphite_potential]
  [../]
[]

[AuxVariables]
  [./temperature]
    initial_condition = 1200.0
  [../]
[]

[Kernels]
  [./electric_graphite]
    type = ConductivityLaplacian
    variable = graphite_potential
    conductivity_coefficient = graphite_electrical_conductivity
  [../]
[]

[BCs]
  [./elec_top]
    type = DirichletBC
    variable = graphite_potential
    boundary = top
    value = 10
  [../]
  [./elec_bottom]
    type = DirichletBC
    variable = graphite_potential
    boundary = bottom
    value = 0
  [../]
[]

[Materials]
  [./graphite_electrical_conductivity]
    type = DerivativeParsedMaterial
    f_name = graphite_electrical_conductivity
    args = 'temperature'
    function = '-2.705e-15 * temperature^2 + 1.263e-11 * temperature^2
                - 1.836e-8 * temperature + 1.813e-5' #in \Omega/(m)
    output_properties = graphite_electrical_conductivity
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
  [./graphite_electrical_conductivity]
    type = ElementAverageValue
    variable = graphite_electrical_conductivity
  [../]
  [./graphite_potential]
    type = AverageNodalVariableValue
    variable = graphite_potential
  [../]
[]


[Outputs]
  csv = true
  exodus = true
  perf_graph = true
[]
