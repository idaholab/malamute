# This model includes only mechanics on a patch mesh and is intended
# verify the implementation of the piecewise function for the coefficient of
# thermal expansion from Cincotti et al (2007) AIChE Journal, Vol 53 No 3,
# page 710 Figure 7d. The piecewise function is given as a function within
# the input file (thexp_exact), and the value of that function is compared
# at each timestep against the computed strain_{xx} calculated value
#

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [./mesh]
    type = PatchMeshGenerator
    dim = 2
  [../]
  coord_type = RZ
[]

[AuxVariables]
  [./temperature]
    initial_condition = 300.0
  [../]
[]

[AuxKernels]
  [./temp_aux]
    type = FunctionAux
    variable = temperature
    function = temp_ramp
  [../]
[]

[Functions]
  [./temp_ramp]
    type = ParsedFunction
    expression = '300 + 400.0/60.*t' #stand-in for a 400C/min heating rate
  [../]
  [./thermal_expansion]
    type = ParsedFunction
    symbol_names = T
    symbol_values = temperature
    expression = '(1.996e-6*log(T*4.799e-2)-4.041e-6)'
  [../]
  [./thexp_exact]
    type = ParsedFunction
    symbol_names = 'ref_temperature thermal_expansion temperature'
    symbol_values = '300.0 thermal_expansion temperature'
    expression = 'thermal_expansion * (temperature - ref_temperature)'
  [../]
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [./all]
        strain = SMALL
        decomposition_method = EigenSolution
        add_variables = true
        use_automatic_differentiation = true
        eigenstrain_names = graphite_thermal_expansion
        generate_output = 'strain_xx'
      [../]
    [../]
  [../]
[]

[BCs]
  [./left]
    type = ADDirichletBC
    variable = disp_x
    value = 0
    boundary = left
  [../]
  [./bottom]
    type = ADDirichletBC
    variable = disp_y
    value = 0
    boundary = bottom
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 1
    poissons_ratio = 0.3
  [../]
  [./graphite_thermal_expansion]
    type = ADGraphiteThermalExpansionEigenstrain
    eigenstrain_name = graphite_thermal_expansion
    stress_free_temperature = 300
    temperature = temperature
  [../]
  [./stress]
    type = ADComputeLinearElasticStress
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  automatic_scaling = true
  compute_scaling_once = true

  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm          ilu         1'
  nl_max_its = 20
  l_max_its = 50
  dt = 25
  dtmin = 1.0e-8
  end_time = 300
[]

[Postprocessors]
  [./temperature]
    type = ElementAverageValue
    variable = temperature
  [../]
  [./strain_xx]
    type = ElementAverageValue
    variable = strain_xx
  [../]
  [./thexp_exact]
    type = FunctionValuePostprocessor
    function = thexp_exact
  [../]
  [./thexp_diff]
    type = DifferencePostprocessor
    value1 = strain_xx
    value2 = thexp_exact
    outputs = none
  [../]
  [./thexp_max_diff]
    type = TimeExtremeValue
    postprocessor = thexp_diff
    value_type = abs_max
  [../]
[]


[Outputs]
  csv = true
  perf_graph = true
  file_base = graphite_thermal_expansion_out
[]
