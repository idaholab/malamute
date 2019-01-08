endtime=500e-5
timestep=.5e-5
surfacetemp=300
bottomtemp=300
pooldepth=2e-4

[GlobalParams]
  gravity = '0 0 0'
  pspg = true
  supg = true
  laplace = true
  integrate_p_by_parts = true
  convective_term = true
  transient_term = true
  temperature = T
  order = SECOND
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = -4e-4
  xmax = 4e-4
  ymin = -2e-4
  ymax = 0
  nx = 4
  ny = 1
  displacements = 'disp_x disp_y'
  elem_type = QUAD9
  uniform_refine = 1
[]

[Problem]
  kernel_coverage_check = false
[]

[Variables]
  [./vel_x]
    [./InitialCondition]
      type = ConstantIC
      value = 1e-15
    [../]
  [../]

  [./vel_y]
    [./InitialCondition]
      type = ConstantIC
      value = 1e-15
    [../]
  [../]

  [./T]
  [../]

  [./p]
    order = FIRST
  [../]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
[]

[ICs]
  [./T]
    type = FunctionIC
    variable = T
    function = '(${surfacetemp} - ${bottomtemp}) / ${pooldepth} * z + ${surfacetemp}'
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
  [./mesh_x]
    type = INSConvectedMesh
    variable = vel_x
    disp_x = disp_x
    disp_y = disp_y
    use_displaced_mesh = true
  [../]
  [./mesh_y]
    type = INSConvectedMesh
    variable = vel_y
    disp_x = disp_x
    disp_y = disp_y
    use_displaced_mesh = true
  [../]
  [./mesh_T]
    type = INSTemperatureConvectedMesh
    variable = T
    disp_x = disp_x
    disp_y = disp_y
    use_displaced_mesh = true
  [../]

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
    type = INSADMomentumBase
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
    type = INSADMomentumBase
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
    boundary = 'bottom'
    value = 0
  [../]
  [./y_no_disp]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom'
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
    value = ${bottomtemp}
  [../]
[]

[ADBCs]
  [./radiation_flux]
    type = RadiationEnergyFluxBC
    variable = T
    boundary = 'top'
    ff_temp = ${bottomtemp}
    sb_constant = 'sb_constant'
    absorptivity = 'abs'
    use_displaced_mesh = true
  [../]

  [./weld_flux]
    type = GaussianWeldEnergyFluxBC
    variable = T
    boundary = 'top'
    reff = 0.6
    F0 = 2.546e9
    R = 1e-4
    x_beam_coord = 0
    y_beam_coord = 0
    z_beam_coord = 0
    use_displaced_mesh = true
  [../]

  [./vapor_recoil_x]
    type = VaporRecoilPressureMomentumFluxBC
    variable = vel_x
    boundary = 'top'
    component = 0
    use_displaced_mesh = true
  [../]

  [./vapor_recoil_y]
    type = VaporRecoilPressureMomentumFluxBC
    variable = vel_y
    boundary = 'top'
    component = 1
    use_displaced_mesh = true
  [../]

  [./surface_x]
    type = SurfaceTensionBC
    variable = vel_x
    boundary = 'top'
    component = 0
    use_displaced_mesh = true
  [../]

  [./surface_y]
    type = SurfaceTensionBC
    variable = vel_y
    boundary = 'top'
    component = 1
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
    beta = 1e7
  [../]
  [./boundary]
    type = CrazyKCPlantFitsBoundary
    boundary = 'top'
    temperature = T
    use_displaced_mesh = true
  [../]
[]

[Materials]
  [./const]
    type = GenericConstantMaterial
    prop_names = 'abs sb_constant'
    prop_values = '1 5.67e-8'
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
  end_time = ${endtime}
  dtmin = 1e-8
  num_steps = 3
  petsc_options = '-snes_converged_reason -ksp_converged_reason -options_left -ksp_monitor_singular_value'
  petsc_options_iname = '-ksp_max_it -ksp_gmres_restart -pc_type'
  petsc_options_value = '1000	     200	        asm'

  line_search = 'none'
  nl_max_its = 12
  l_tol = 1e-3
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
    show_material_properties = 'mu surface_term_curvature surface_term_gradient1 surface_term_gradient2'
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
  max_h_level = 1
  initial_steps = 0

  [./Indicators]
    [./error_x]
      type = GradientJumpIndicator
      variable = vel_x
    [../]
    [./error_y]
      type = GradientJumpIndicator
      variable = vel_y
    [../]
    # [./error_p]
    #   type = GradientJumpIndicator
    #   variable = p
    # [../]
    [./error_T]
      type = GradientJumpIndicator
      variable = T
    [../]
    [./error_dispx]
      type = GradientJumpIndicator
      variable = disp_x
    [../]
    [./error_dispy]
      type = GradientJumpIndicator
      variable = disp_y
    [../]
  [../]

  [./Markers]
    [./errorfrac_x]
      type = ErrorFractionMarker
      refine = 0.4
      coarsen = 0.2
      indicator = error_x
    [../]
    [./errorfrac_y]
      type = ErrorFractionMarker
      refine = 0.4
      coarsen = 0.2
      indicator = error_y
    [../]
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
    [./errorfrac_dispx]
      type = ErrorFractionMarker
      refine = 0.4
      coarsen = 0.2
      indicator = error_dispx
    [../]
    [./errorfrac_dispy]
      type = ErrorFractionMarker
      refine = 0.4
      coarsen = 0.2
      indicator = error_dispy
    [../]
    [./combo]
      type = ComboMarker
      markers = 'errorfrac_x errorfrac_y  errorfrac_T errorfrac_dispx errorfrac_dispy'
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
