[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 20
  ny = 20
[]

[Adaptivity]
  initial_marker = marker
  initial_steps = 2
  max_h_level = 2
  [Markers]
    [marker]
      type = BoxMarker
      bottom_left = '0.25 0.25 0'
      top_right = '0.75 0.75 0'
      inside = REFINE
      outside = DO_NOTHING
    []
  []
[]

[AuxVariables]
  [ls]
  []
[]

[AuxKernels]
  [ls_aux]
    type = FunctionAux
    variable = ls
    function = ls_func
    execute_on = initial
  []
[]

[Variables]
  [curvature]
  []
  [grad_ls]
    family = LAGRANGE_VEC
  []
[]

[Kernels]
  [curvature]
    type = LevelSetCurvatureRegularization
    level_set_regularized_gradient = grad_ls
    variable = curvature
    varepsilon = 0.04
  []
  [grad_ls]
    type = VariableGradientRegularization
    regularized_var = ls
    variable = grad_ls
  []
[]

[Functions]
  [ls_func]
    type = LevelSetOlssonBubble
    center = '0.5 0.5 0'
    radius = 0.15
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
    solve_type = 'NEWTON'
  []
[]

[Executioner]
  type = Steady
  line_search = 'none'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

[Outputs]
  exodus = true
[]
