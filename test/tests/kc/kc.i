epsilon='1E-15'

[GlobalParams]
  gravity = '0 0 0'
  pspg = true
  supg = true
  laplace = true
  integrate_p_by_parts = true
  convective_term = true
  transient_term = true
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = -.1e-3
  xmax = 0.1e-3
  ymin = -.1e-3
  ymax = 0
  nx = 4
  ny = 4
  displacements = 'disp_x disp_y'
  uniform_refine = 2
[]

[MeshModifiers]
  [./corner_node]
    type = AddExtraNodeset
    new_boundary = 'pinned_node'
    nodes = '0'
  [../]
[]

[Variables]
  [./vel_x]
    [./InitialCondition]
      type = ConstantIC
      value = ${epsilon}
    [../]
  [../]

  [./vel_y]
    [./InitialCondition]
      type = ConstantIC
      value = ${epsilon}
    [../]
  [../]

  [./T]
    [./InitialCondition]
      type = ConstantIC
      value = 300
    [../]
  [../]

  [./p]
  [../]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
[]

[Kernels]
  [./disp_x]
    type = Diffusion
    variable = disp_x
  [../]
  [./disp_y]
    type = Diffusion
    variable = disp_y
  [../]
[]

[ADKernels]
  # mass
  [./mass]
    type = INSADMass
    variable = p
    u = vel_x
    v = vel_y
    p = p
    use_displaced_mesh = true
  [../]

  # x-momentum, time
  [./x_momentum_time]
    type = INSADMomentumTimeDerivative
    variable = vel_x
    use_displaced_mesh = true
  [../]

  # x-momentum, space
  [./x_momentum_space]
    type = INSADMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    p = p
    component = 0
    use_displaced_mesh = true
  [../]

  # y-momentum, time
  [./y_momentum_time]
    type = INSADMomentumTimeDerivative
    variable = vel_y
    use_displaced_mesh = true
  [../]

  # y-momentum, space
  [./y_momentum_space]
    type = INSADMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    p = p
    component = 1
    use_displaced_mesh = true
  [../]

 # temperature
 [./temperature_time]
   type = INSADTemperatureTimeDerivative
   variable = T
   use_displaced_mesh = true
 [../]

 [./temperature_space]
   type = INSADTemperature
   variable = T
   u = vel_x
   v = vel_y
   p = p
   use_displaced_mesh = true
 [../]
[]

[BCs]
  [./x_no_disp]
    type = DirichletBC
    variable = disp_x
    boundary = 'bottom right left'
    value = 0
  [../]
  [./y_no_disp]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom right left'
    value = 0
  [../]

  [./x_no_slip]
    type = DirichletBC
    variable = vel_x
    boundary = 'bottom right left'
    value = 0.0
  [../]

  [./y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'bottom right left'
    value = 0.0
  [../]

  [./T_cold]
    type = DirichletBC
    variable = T
    boundary = 'bottom'
    value = 300
  [../]

  [./weld_flux]
    type = GaussianWeldEnergyFluxBC
    variable = T
    boundary = 'top'
    reff = 0.6
    F0 = 2.546e9
    R = 1e-4
    beam_coords = '0 0 0'
    use_displaced_mesh = true
  [../]
[]

[ADBCs]
  [./radiation_flux]
    type = RadiationEnergyFluxBC
    variable = T
    boundary = 'top'
    ff_temp = 1
    sb_constant = 'sb_constant'
    absorptivity = 'abs'
    use_displaced_mesh = true
  [../]

  [./vapor_recoil_x]
    type = VaporRecoilPressureMomentumFluxBC
    temperature = T
    variable = vel_x
    boundary = 'top'
    component = 0
    use_displaced_mesh = true
    # ap2 = 0
    # bp1 = 0
  [../]

  [./vapor_recoil_y]
    type = VaporRecoilPressureMomentumFluxBC
    temperature = T
    variable = vel_y
    boundary = 'top'
    component = 1
    # ap2 = 0
    # bp1 = 0
    use_displaced_mesh = true
  [../]

  [./displace_x_top]
    type = DisplaceBoundaryBC
    boundary = 'top'
    variable = 'disp_x'
    velocity = 'vel_x'
  [../]
  [./displace_y_top]
    type = DisplaceBoundaryBC
    boundary = 'top'
    variable = 'disp_y'
    velocity = 'vel_y'
  [../]
[]

[ADMaterials]
  [./kc_fits]
    type = CrazyKCPlantFits
    temperature = T
    # c_mu1 = 0
    # c_mu2 = 0
    # c_mu3 = 0
  [../]
[]

[Materials]
  [./const]
    type = GenericConstantMaterial
    prop_names = 'abs sb_constant'
    # prop_values = '1  1'
    prop_values = '1 5.67e-8'
  [../]
  # [./sub]
  #   type = GenericConstantMaterial
  #   block = 0
  #   prop_names = 'rho cp k'
  #   prop_values = '1  1  .1'
  # [../]
[]

[Functions]
  [./lid_function]
    # We pick a function that is exactly represented in the velocity
    # space so that the Dirichlet conditions are the same regardless
    # of the mesh spacing.
    type = ParsedFunction
    value = '-1 / .1225 * x^2 + 1'
  [../]
[]

[Preconditioning]
  [./SMP]
    type = FDP
    full = true
    solve_type = 'NEWTON'
  [../]
[]

[Executioner]
  type = Transient
  # Run for 100+ timesteps to reach steady state.
  end_time = 10000
  # num_steps = 1
  dtmin = 1e-6
  petsc_options = '-snes_converged_reason -ksp_converged_reason -options_left'
  # petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -snes_linesearch_minlambda -pc_factor_mat_solver_package'
  # petsc_options_value = 'lu       NONZERO               1                   1e-3                       superlu_dist'
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  petsc_options_value = 'hypre boomeramg         101'

  line_search = 'none'
  nl_max_its = 12
  l_max_its = 100
  [./TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 6
    dt = 1e-6
  [../]
[]

[Outputs]
  file_base = kc_out
  [./exodus]
    type = Exodus
    output_material_properties = true
    show_material_properties = 'mu'
  [../]
  [./dofmap]
    type = DOFMap
    execute_on = 'initial'
  [../]
  checkpoint = true
[]

[Debug]
  show_var_residual_norms = true
[]


[Adaptivity]
  marker = combo
  max_h_level = 3

  [./Indicators]
    [./error_x]
      type = GradientJumpIndicator
      variable = vel_x
    [../]
    [./error_y]
      type = GradientJumpIndicator
      variable = vel_y
    [../]
    [./error_p]
      type = GradientJumpIndicator
      variable = p
    [../]
    [./error_T]
      type = GradientJumpIndicator
      variable = T
    [../]
  [../]

  [./Markers]
    [./errorfrac_x]
      type = ErrorFractionMarker
      refine = 0.9
      coarsen = 0.1
      indicator = error_x
    [../]
    [./errorfrac_y]
      type = ErrorFractionMarker
      refine = 0.9
      coarsen = 0.1
      indicator = error_y
    [../]
    [./errorfrac_p]
      type = ErrorFractionMarker
      refine = 0.9
      coarsen = 0.1
      indicator = error_p
    [../]
    [./errorfrac_T]
      type = ErrorFractionMarker
      refine = 0.9
      coarsen = 0.1
      indicator = error_T
    [../]
    [./combo]
      type = ComboMarker
      markers = 'errorfrac_x errorfrac_y errorfrac_T errorfrac_p'
    [../]
  [../]
[]

[Postprocessors]
  [./num_dofs]
    type = NumDOFs
    system = 'NL'
  [../]
[]
