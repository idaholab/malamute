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
  xmin = -1
  xmax = 1
  ymin = -1
  ymax = 0
  nx = 1
  ny = 1
  displacements = 'disp_x disp_y'
  # uniform_refine = 3
[]

[Problem]
  kernel_coverage_check = false
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
      value = 1
    [../]
  [../]

  [./vel_y]
    [./InitialCondition]
      type = ConstantIC
      value = 1
    [../]
  [../]

  [./T]
    [./InitialCondition]
      type = ConstantIC
      value = 1
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

  # [./weld_flux]
  #   type = GaussianWeldEnergyFluxBC
  #   variable = T
  #   boundary = 'top'
  #   reff = 1
  #   F0 = 1
  #   R = 1
  #   beam_coords = '0 0 0'
  #   use_displaced_mesh = true
  # [../]
[]

# [ADBCs]
#   [./radiation_flux]
#     type = RadiationEnergyFluxBC
#     variable = T
#     boundary = 'top'
#     ff_temp = 1
#     sb_constant = 'sb_constant'
#     absorptivity = 'abs'
#     use_displaced_mesh = true
#   [../]

#   [./vapor_recoil_x]
#     type = VaporRecoilPressureMomentumFluxBC
#     temperature = T
#     variable = vel_x
#     boundary = 'top'
#     component = 0
#     use_displaced_mesh = true
#     # ap2 = 0
#     # bp1 = 0
#   [../]

#   [./vapor_recoil_y]
#     type = VaporRecoilPressureMomentumFluxBC
#     temperature = T
#     variable = vel_y
#     boundary = 'top'
#     component = 1
#     # ap2 = 0
#     # bp1 = 0
#     use_displaced_mesh = true
#   [../]

#   [./displace_x_top]
#     type = DisplaceBoundaryBC
#     boundary = 'top'
#     variable = 'disp_x'
#     velocity = 'vel_x'
#   [../]
#   [./displace_y_top]
#     type = DisplaceBoundaryBC
#     boundary = 'top'
#     variable = 'disp_y'
#     velocity = 'vel_y'
#   [../]
# []

[ADMaterials]
  [./kc_fits]
    type = CrazyKCPlantFits
    c_mu0 = 1
    c_mu1 = 1
    c_mu2 = 1
    c_mu3 = 1
    Tmax = 3
    Tl = 2
    T90 = 1
    beta = 1
    c_k0 = 1
    c_k1 = 1
    c_cp0 = 1
    c_cp1 = 1
    c_rho0 = 1
  [../]
[]

[Materials]
  [./const]
    type = GenericConstantMaterial
    prop_names = 'abs sb_constant'
    # prop_values = '1  1'
    prop_values = '1 1'
  [../]
  # [./sub]
  #   type = GenericConstantMaterial
  #   block = 0
  #   prop_names = 'rho cp k'
  #   prop_values = '1  1  .1'
  # [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
    solve_type = 'NEWTON'
  [../]
[]

[Executioner]
  type = Transient
  # Run for 100+ timesteps to reach steady state.
  end_time = 10000
  num_steps = 1
  dtmin = 1
  petsc_options = '-snes_converged_reason -ksp_converged_reason -options_left -snes_test_jacobian -snes_test_jacobian_view'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -snes_linesearch_minlambda -pc_factor_mat_solver_type -mat_mffd_err -snes_force_iteration'
  petsc_options_value = 'lu       NONZERO               1e-15                   1e-3                       superlu_dist               1e-5          1'

  line_search = 'bt'
  nl_max_its = 1
  l_max_its = 100
  [./TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 6
    dt = 1
    linear_iteration_ratio = 1e6
  [../]
[]

[Outputs]
  file_base = kc_jacobian_tester
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


# [Adaptivity]
#   marker = combo
#   max_h_level = 5

#   [./Indicators]
#     [./error_x]
#       type = GradientJumpIndicator
#       variable = vel_x
#     [../]
#     [./error_y]
#       type = GradientJumpIndicator
#       variable = vel_y
#     [../]
#     [./error_p]
#       type = GradientJumpIndicator
#       variable = p
#     [../]
#     [./error_T]
#       type = GradientJumpIndicator
#       variable = T
#     [../]
#     [./error_dispx]
#       type = GradientJumpIndicator
#       variable = disp_x
#     [../]
#     [./error_dispy]
#       type = GradientJumpIndicator
#       variable = disp_y
#     [../]
#   [../]

#   [./Markers]
#     [./errorfrac_x]
#       type = ErrorFractionMarker
#       refine = 0.9
#       coarsen = 0.1
#       indicator = error_x
#     [../]
#     [./errorfrac_y]
#       type = ErrorFractionMarker
#       refine = 0.9
#       coarsen = 0.1
#       indicator = error_y
#     [../]
#     [./errorfrac_p]
#       type = ErrorFractionMarker
#       refine = 0.9
#       coarsen = 0.1
#       indicator = error_p
#     [../]
#     [./errorfrac_T]
#       type = ErrorFractionMarker
#       refine = 0.9
#       coarsen = 0.1
#       indicator = error_T
#     [../]
#     [./errorfrac_dispx]
#       type = ErrorFractionMarker
#       refine = 0.9
#       coarsen = 0.1
#       indicator = error_dispx
#     [../]
#     [./errorfrac_dispy]
#       type = ErrorFractionMarker
#       refine = 0.9
#       coarsen = 0.1
#       indicator = error_dispy
#     [../]
#     [./combo]
#       type = ComboMarker
#       markers = 'errorfrac_x errorfrac_y errorfrac_T errorfrac_p errorfrac_dispx errorfrac_dispy'
#     [../]
#   [../]
# []

[Postprocessors]
  [./num_dofs]
    type = NumDOFs
    system = 'NL'
  [../]
[]
