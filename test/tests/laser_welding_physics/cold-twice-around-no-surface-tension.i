period=1.25e-3
endtime=2.5e-3
timestep=1.25e-5
surfacetemp=300

# [GlobalParams]
#   gravity = '0 0 0'
#   pspg = true
#   # supg = true
#   laplace = true
#   integrate_p_by_parts = true
#   convective_term = true
#   transient_term = true
# []

[Mesh]
  type = GeneratedMesh
  dim = 3
  xmin = -.35e-3
  xmax = 0.35e-3
  ymin = -.35e-3
  ymax = .35e-3
  zmin = -.7e-3
  zmax = 0
  nx = 4
  ny = 4
  nz = 4
  displacements = 'disp_x disp_y disp_z'
  uniform_refine = 2
[]

[Variables]
  [./velocity]
    order = FIRST
    family = LAGRANGE_VEC
    [./InitialCondition]
      type = VectorConstantIC
      x_value = 1e-15
      y_value = 1e-15
      z_value = 1e-15
    [../]
  [../]

  [./T]
  [../]

  [./p]
  [../]

  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
  [../]
[]

[AuxVariables]
  [./vel_x_aux]
    [./InitialCondition]
      type = ConstantIC
      value = 1e-15
    [../]
  [../]
  [./vel_y_aux]
    [./InitialCondition]
      type = ConstantIC
      value = 1e-15
    [../]
  [../]
  [./vel_z_aux]
    [./InitialCondition]
      type = ConstantIC
      value = 1e-15
    [../]
  [../]
[]

[ICs]
  [./T]
    type = FunctionIC
    variable = T
    function = '(${surfacetemp} - 300) / .7e-3 * z + ${surfacetemp}'
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
  [./disp_z]
    type = Diffusion
    variable = disp_z
  [../]

  # mass
  [./mass_pspg]
    type = INSADMassPSPG
    variable = p
    use_displaced_mesh = true
  [../]

  # momentum
  [./momentum_time]
    type = INSADMomentumTimeDerivative
    variable = velocity
    use_displaced_mesh = true
  [../]
  [./momentum_advection]
    type = INSADMomentumAdvection
    variable = velocity
    use_displaced_mesh = true
  [../]
  [./momentum_viscous]
    type = INSADMomentumViscous
    variable = velocity
    viscous_form = laplace
    use_displaced_mesh = true
  [../]
  [./momentum_pressure]
    type = INSADMomentumPressure
    variable = velocity
    integrate_p_by_parts = true
    pressure = p
    use_displaced_mesh = true
  [../]

  # temperature
  [./temperature_time]
    type = INSADHeatConductionTimeDerivative
    variable = T
    use_displaced_mesh = true
  [../]
  [./temperature_advection]
    type = INSADEnergyAdvection
    variable = T
    use_displaced_mesh = true
  [../]
  [./temperature_conduction]
    type = ADHeatConduction
    variable = T
    thermal_conductivity = k
    use_displaced_mesh = true
  [../]

  # mesh
  [./mesh_velocity]
    type = BaldrConvectedMesh
    variable = velocity
    disp_x = disp_x
    disp_y = disp_y
    disp_z = disp_z
    use_displaced_mesh = true
  [../]
  [mesh_T]
    type = BaldrTemperatureConvectedMesh
    variable = T
    disp_x = disp_x
    disp_y = disp_y
    disp_z = disp_z
    use_displaced_mesh = true
  []
[]

[AuxKernels]
  [./vel_x_value]
    type = VectorVariableComponentAux
    variable = vel_x_aux
    vector_variable = velocity
    component = x
  [../]
  [./vel_y_value]
    type = VectorVariableComponentAux
    variable = vel_y_aux
    vector_variable = velocity
    component = y
  [../]
  [./vel_z_value]
    type = VectorVariableComponentAux
    variable = vel_z_aux
    vector_variable = velocity
    component = z
  [../]
[]

[BCs]
  [./x_no_disp]
    type = DirichletBC
    variable = disp_x
    boundary = 'back'
    value = 0
  [../]
  [./y_no_disp]
    type = DirichletBC
    variable = disp_y
    boundary = 'back'
    value = 0
  [../]
  [./z_no_disp]
    type = DirichletBC
    variable = disp_z
    boundary = 'back'
    value = 0
  [../]

  [./velocity_no_slip]
    type = VectorDirichletBC
    variable = velocity
    boundary = 'bottom right left top back'
    values = '0 0 0'
  [../]

  [./T_cold]
    type = DirichletBC
    variable = T
    boundary = 'back'
    value = 300
  [../]

  [./radiation_flux]
    type = RadiationEnergyFluxBC
    variable = T
    boundary = 'front'
    ff_temp = 300
    sb_constant = 'sb_constant'
    absorptivity = 'abs'
    use_displaced_mesh = true
  [../]

  [./weld_flux]
    type = GaussianWeldEnergyFluxBC
    variable = T
    boundary = 'front'
    reff = 0.6
    F0 = 2.546e9
    R = 1e-4
    x_beam_coord = '2e-4 * cos(t * 2 * pi / ${period})'
    y_beam_coord = '2e-4 * sin(t * 2 * pi / ${period})'
    z_beam_coord = 0
    use_displaced_mesh = true
  [../]

  [./vapor_recoil]
    type = VaporRecoilPressureMomentumFluxBC
    variable = velocity
    boundary = 'front'
    use_displaced_mesh = true
  [../]

  [./displace_x_top]
    type = DisplaceBoundaryBC
    boundary = 'front'
    variable = 'disp_x'
    velocity = 'vel_x_aux'
  [../]
  [./displace_y_top]
    type = DisplaceBoundaryBC
    boundary = 'front'
    variable = 'disp_y'
    velocity = 'vel_y_aux'
  [../]
  [./displace_z_top]
    type = DisplaceBoundaryBC
    boundary = 'front'
    variable = 'disp_z'
    velocity = 'vel_z_aux'
  [../]
[]

[Materials]
  [./kc_fits]
    type = CrazyKCPlantFits
    temperature = T
    beta = 1e7
  [../]
  [./boundary]
    type = CrazyKCPlantFitsBoundary
    boundary = 'front'
    temperature = T
  [../]
  [./const]
    type = ADGenericConstantMaterial
    prop_names = 'abs sb_constant'
    prop_values = '1 5.67e-8'
  [../]
  [ins_mat]
    type = INSADStabilized3Eqn
    velocity = velocity
    pressure = p
    temperature = T
  []
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
  end_time = ${endtime}
  dtmin = 1e-8
  dtmax = ${timestep}
  petsc_options = '-snes_converged_reason -ksp_converged_reason -options_left -ksp_monitor_singular_value'
  petsc_options_iname = '-ksp_gmres_restart -pc_type'
  petsc_options_value = '100        lu'

  line_search = 'none'
  nl_max_its = 12
  l_max_its = 100
  [./TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 7
    dt = ${timestep}
    linear_iteration_ratio = 1e6
    growth_factor = 1.5
  [../]
[]

[Outputs]
  print_linear_residuals = false
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
  max_h_level = 4

  [./Indicators]
    # [./error_x]
    #   type = GradientJumpIndicator
    #   variable = vel_x
    # [../]
    # [./error_y]
    #   type = GradientJumpIndicator
    #   variable = vel_y
    # [../]
    # [./error_z]
    #   type = GradientJumpIndicator
    #   variable = vel_z
    # [../]
    # [./error_p]
    #   type = GradientJumpIndicator
    #   variable = p
    # [../]
    [./error_T]
      type = GradientJumpIndicator
      variable = T
    [../]
    # [./error_dispx]
    #   type = GradientJumpIndicator
    #   variable = disp_x
    # [../]
    # [./error_dispy]
    #   type = GradientJumpIndicator
    #   variable = disp_y
    # [../]
    [./error_dispz]
      type = GradientJumpIndicator
      variable = disp_z
    [../]
  [../]

  [./Markers]
    # [./errorfrac_x]
    #   type = ErrorFractionMarker
    #   refine = 0.7
    #   coarsen = 0.3
    #   indicator = error_x
    # [../]
    # [./errorfrac_y]
    #   type = ErrorFractionMarker
    #   refine = 0.7
    #   coarsen = 0.3
    #   indicator = error_y
    # [../]
    # [./errorfrac_z]
    #   type = ErrorFractionMarker
    #   refine = 0.7
    #   coarsen = 0.3
    #   indicator = error_z
    # [../]
    # [./errorfrac_p]
    #   type = ErrorFractionMarker
    #   refine = 0.7
    #   coarsen = 0.3
    #   indicator = error_p
    # [../]
    [./errorfrac_T]
      type = ErrorFractionMarker
      refine = 0.4
      coarsen = 0.2
      indicator = error_T
    [../]
    # [./errorfrac_dispx]
    #   type = ErrorFractionMarker
    #   refine = 0.7
    #   coarsen = 0.3
    #   indicator = error_dispx
    # [../]
    # [./errorfrac_dispy]
    #   type = ErrorFractionMarker
    #   refine = 0.7
    #   coarsen = 0.3
    #   indicator = error_dispy
    # [../]
    [./errorfrac_dispz]
      type = ErrorFractionMarker
      refine = 0.4
      coarsen = 0.2
      indicator = error_dispz
    [../]
    [./combo]
      type = ComboMarker
      markers = 'errorfrac_T errorfrac_dispz'
    [../]
  [../]
[]

[Postprocessors]
  [./num_dofs]
    type = NumDOFs
    system = 'NL'
  [../]
  [./nl]
    type = NumNonlinearIterations
  [../]
  [./tot_nl]
    type = CumulativeValuePostprocessor
    postprocessor = 'nl'
  [../]
  [./linear]
    type = NumLinearIterations
  [../]
  [./tot_linear]
    type = CumulativeValuePostprocessor
    postprocessor = 'linear'
  [../]
[]
