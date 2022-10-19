[Mesh/gen]
  type = GeneratedMeshGenerator
  dim = 2
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 1
  nx = 40
  ny = 40
  elem_type = QUAD4
[]

[ICs]
  [ls_ic]
    type = FunctionIC
    function = ls_exact
    variable = ls
  []
[]

[Variables]
  [ls]
  []
  [grad_ls]
    family = LAGRANGE_VEC
  []
[]

[Functions/ls_exact]
  type = LevelSetOlssonPlane
  epsilon = 0.04
  point = '0.5 0.5 0'
  normal = '0 1 0'
[]

[Kernels]
  [level_set_time]
    type = ADTimeDerivative
    variable = ls
  []

  [level_set_mass]
    type = LevelSetPowderAddition
    laser_location_x = '0.5 + t'
    laser_location_y = '0.5'
    powder_density = 6000
    eta_p = 1
    mass_scale = 1
    mass_radius = 0.2
    mass_rate = 1000
    variable = ls
  []

  [grad_ls]
    type = VariableGradientRegularization
    regularized_var = ls
    variable = grad_ls
  []
[]

[Materials]
  [delta]
    type = LevelSetDeltaFunction
    level_set_gradient = grad_ls
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
  type = Transient
  solve_type = NEWTON
  dt = 1e-2
  nl_abs_tol = 1e-12
  num_steps = 2
[]

[Outputs]
  exodus = true
[]
