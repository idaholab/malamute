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
  dim = 1
  xmin = -1
  xmax = 1
  ymin = -1
  ymax = 1
  zmin = -1
  zmax = 0
  nx = 2
  ny = 1
  nz = 1
  # displacements = 'disp_x disp_y disp_z'
  displacements = 'disp_x'
[]

[Problem]
  kernel_coverage_check = false
[]

[Variables]
  [./disp_x]
  [../]
  [./p]
  [../]
  [./vel_x]
  [../]

  # [./vel_y]
  # [../]

  # [./vel_z]
  # [../]

  [./T]
  [../]

  # [./disp_y]
  # [../]
  # [./disp_z]
  # [../]
[]

[Kernels]
  [./disp_x]
    type = Diffusion
    variable = disp_x
  [../]
  # [./disp_y]
  #   type = Diffusion
  #   variable = disp_y
  # [../]
  # [./disp_z]
  #   type = Diffusion
  #   variable = disp_z
  # [../]
  [./mesh_x]
    type = INSConvectedMesh
    variable = vel_x
    disp_x = disp_x
    # disp_y = disp_y
    # disp_z = disp_z
    use_displaced_mesh = true
  [../]
  # [./mesh_y]
  #   type = INSConvectedMesh
  #   variable = vel_x
  #   disp_x = disp_x
  #   disp_y = disp_y
  #   # disp_z = disp_z
  # [../]
  # [./mesh_z]
  #   type = INSConvectedMesh
  #   variable = vel_x
  #   disp_x = disp_x
  #   disp_y = disp_y
  #   disp_z = disp_z
  # [../]
[]

[ADKernels]
  # mass
  [./mass]
    type = INSADMass
    variable = p
    u = vel_x
    # v = vel_y
    # w = vel_z
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
    type = INSADMomentumBase
    variable = vel_x
    u = vel_x
    # v = vel_y
    # w = vel_z
    p = p
    component = 0
    use_displaced_mesh = true
  [../]

  # # y-momentum, time
  # [./y_momentum_time]
  #   type = INSADMomentumTimeDerivative
  #   variable = vel_y
  #   use_displaced_mesh = true
  # [../]

  # # y-momentum, space
  # [./y_momentum_space]
  #   type = INSADMomentumBase
  #   variable = vel_y
  #   u = vel_x
  #   v = vel_y
  #   # w = vel_z
  #   p = p
  #   component = 1
  #   use_displaced_mesh = true
  # [../]

  # # z-momentum, time
  # [./z_momentum_time]
  #   type = INSADMomentumTimeDerivative
  #   variable = vel_z
  #   use_displaced_mesh = true
  # [../]

  # # z-momentum, space
  # [./z_momentum_space]
  #   type = INSADMomentumBase
  #   variable = vel_z
  #   u = vel_x
  #   v = vel_y
  #   w = vel_z
  #   p = p
  #   component = 2
  #   use_displaced_mesh = true
  # [../]

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
   # v = vel_y
   # w = vel_z
   p = p
   use_displaced_mesh = true
 [../]
[]

[BCs]
  [./x_no_disp]
    type = DirichletBC
    variable = disp_x
    boundary = 'right'
    value = 0
  [../]
#   [./y_no_disp]
#     type = DirichletBC
#     variable = disp_y
#     boundary = 'bottom right left top back'
#     value = 0
#   [../]
#   [./z_no_disp]
#     type = DirichletBC
#     variable = disp_z
#     boundary = 'bottom right left top back'
#     value = 0
#   [../]

  [./x_no_slip]
    type = DirichletBC
    variable = vel_x
    boundary = 'right'
    value = 0.0
  [../]

#   [./y_no_slip]
#     type = DirichletBC
#     variable = vel_y
#     boundary = 'bottom right left top back'
#     value = 0.0
#   [../]

#   [./z_no_slip]
#     type = DirichletBC
#     variable = vel_z
#     boundary = 'bottom right left top back'
#     value = 0.0
#   [../]

  [./T_cold]
    type = DirichletBC
    variable = T
    boundary = 'right'
    value = 1
  [../]
[]

[ADBCs]
  [./radiation_flux]
    type = RadiationEnergyFluxBC
    variable = T
    boundary = 'left'
    ff_temp = 1
    use_displaced_mesh = true
  [../]
  [./weld_flux]
    type = GaussianWeldEnergyFluxBC
    variable = T
    boundary = 'left'
    reff = 1
    F0 = 1
    R = 1
    x_beam_coord = 0
    y_beam_coord = 0
    z_beam_coord = 0
    use_displaced_mesh = true
  [../]

  [./vapor_recoil_x]
    type = VaporRecoilPressureMomentumFluxBC
    variable = vel_x
    boundary = 'left'
    component = 0
    use_displaced_mesh = true
  [../]

#   [./vapor_recoil_y]
#     type = VaporRecoilPressureMomentumFluxBC
#     temperature = T
#     variable = vel_y
#     boundary = 'front'
#     component = 1
#     use_displaced_mesh = true
#   [../]

#   [./vapor_recoil_z]
#     type = VaporRecoilPressureMomentumFluxBC
#     temperature = T
#     variable = vel_z
#     boundary = 'front'
#     component = 2
#     use_displaced_mesh = true
#   [../]

  [./displace_x_top]
    type = DisplaceBoundaryBC
    boundary = 'left'
    variable = 'disp_x'
    velocity = 'vel_x'
  [../]
#   [./displace_y_top]
#     type = DisplaceBoundaryBC
#     boundary = 'front'
#     variable = 'disp_y'
#     velocity = 'vel_y'
#   [../]
#   [./displace_z_top]
#     type = DisplaceBoundaryBC
#     boundary = 'front'
#     variable = 'disp_z'
#     velocity = 'vel_z'
#   [../]
[]

[ADMaterials]
  [./kc_fits]
    type = CrazyKCPlantFits
    temperature = T
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
  [./boundary]
    type = CrazyKCPlantFitsBoundary
    # boundary = 'front'
    boundary = 'left'
    temperature = T
    c_mu0 = 1
    ap0 = 1
    ap1 = 1
    ap2 = 1
    ap3 = 1
    bp0 = 1
    bp1 = 1
    bp2 = 1
    bp3 = 1
    Tb = 1
    Tbound1 = 2
    Tbound2 = 3
  [../]
[]

[Materials]
  [./const]
    type = GenericConstantMaterial
    prop_names = 'abs sb_constant'
    prop_values = '1 1'
  [../]
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
  end_time = 10000
  dt = 1
  dtmin = 1
  num_steps = 2
  petsc_options = '-snes_converged_reason -ksp_converged_reason -options_left -snes_test_jacobian -snes_test_jacobian_view'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -snes_linesearch_minlambda -pc_factor_mat_solver_type -ksp_gmres_restart'
  petsc_options_value = 'lu       NONZERO               1e-15                   1e-3                       superlu_dist               100'

  line_search = 'none'
  nl_max_its = 10
  l_max_its = 100
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

[Postprocessors]
  [./num_dofs]
    type = NumDOFs
    system = 'NL'
  [../]
[]

[ICs]
  [./vel_x]
    type = RandomIC
    min = 0.1
    max = 3.9
    variable = vel_x
  [../]
  # [./vel_y]
  #   type = RandomIC
  #   min = 0.1
  #   max = 3.9
  #   variable = vel_y
  # [../]
  # [./vel_z]
  #   type = RandomIC
  #   min = 0.1
  #   max = 3.9
  #   variable = vel_z
  # [../]
  [./disp_x]
    type = RandomIC
    min = 0.1
    max = 0.2
    variable = disp_x
  [../]
  # [./disp_y]
  #   type = RandomIC
  #   min = 0.1
  #   max = 0.2
  #   variable = disp_y
  # [../]
  # [./disp_z]
  #   type = RandomIC
  #   min = 0.1
  #   max = 0.2
  #   variable = disp_z
  # [../]
  [./p]
    type = RandomIC
    min = 0.1
    max = 3.9
    variable = p
  [../]
  [./T]
    type = RandomIC
    min = 0.1
    max = 3.9
    variable = T
  [../]
[]
