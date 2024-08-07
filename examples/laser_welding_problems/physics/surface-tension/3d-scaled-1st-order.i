length_unit_exponent = -4
temperature_unit_exponent = 3
mass_unit_exponent = -6
time_unit_exponent = -5

endtime = '${fparse 500e-5 / 10^time_unit_exponent}'
period = '${fparse 5e-5 / 10^time_unit_exponent}'
timestep = '${fparse period / 20}'
surfacetemp = '${fparse 300 / 10^temperature_unit_exponent}'
bottomtemp = '${fparse 300 / 10^temperature_unit_exponent}'
width = '${fparse 8e-4 / 10^length_unit_exponent}'
half_width = '${fparse width / 2}'
pooldepth = ${width}

[GlobalParams]
  gravity = '0 0 0'
  pspg = true
  supg = true
  laplace = true
  integrate_p_by_parts = true
  convective_term = true
  transient_term = true
  temperature = T
  order = FIRST
[]

[Mesh]
  type = GeneratedMesh
  dim = 3
  xmin = '${fparse -half_width}'
  xmax = ${half_width}
  ymin = '${fparse -half_width}'
  ymax = ${half_width}
  zmin = '${fparse -pooldepth}'
  zmax = 0
  nx = 2
  ny = 2
  nz = 2
  displacements = 'disp_x disp_y disp_z'
  uniform_refine = 3
[]

[MeshModifiers]
  [corner_node]
    type = AddExtraNodeset
    new_boundary = 'pinned_node'
    nodes = '0'
  []
[]

[Variables]
  [vel_x]
    [InitialCondition]
      type = ConstantIC
      value = 1e-15
    []
    scaling = 1e6
  []

  [vel_y]
    [InitialCondition]
      type = ConstantIC
      value = 1e-15
    []
    scaling = 1e6
  []

  [vel_z]
    [InitialCondition]
      type = ConstantIC
      value = 1e-15
    []
    scaling = 1e6
  []

  [T]
    scaling = 1e1
  []

  [p]
    order = FIRST
    scaling = 1e4
  []
  [disp_x]
    scaling = 1e-3
  []
  [disp_y]
    scaling = 1e-3
  []
  [disp_z]
    scaling = 1e-3
  []
[]

[ICs]
  [T]
    type = FunctionIC
    variable = T
    function = '(${surfacetemp} - ${bottomtemp}) / ${pooldepth} * z + ${surfacetemp}'
  []
[]

[Kernels]
[]

[ADKernels]
  [disp_x]
    type = ADStressDivergence
    variable = disp_x
    component = 0
  []
  [disp_y]
    type = ADStressDivergence
    variable = disp_y
    component = 1
  []
  [disp_z]
    type = ADStressDivergence
    variable = disp_z
    component = 2
  []

  [mesh_x]
    type = INSConvectedMesh
    variable = vel_x
    disp_x = disp_x
    disp_y = disp_y
    disp_z = disp_z
    use_displaced_mesh = true
  []
  [mesh_y]
    type = INSConvectedMesh
    variable = vel_y
    disp_x = disp_x
    disp_y = disp_y
    disp_z = disp_z
    use_displaced_mesh = true
  []
  [mesh_z]
    type = INSConvectedMesh
    variable = vel_z
    disp_x = disp_x
    disp_y = disp_y
    disp_z = disp_z
    use_displaced_mesh = true
  []
  [mesh_T]
    type = INSTemperatureConvectedMesh
    variable = T
    disp_x = disp_x
    disp_y = disp_y
    disp_z = disp_z
    use_displaced_mesh = true
  []

  # mass
  [mass]
    type = INSADMass
    variable = p
    u = vel_x
    v = vel_y
    w = vel_z
    p = p
    use_displaced_mesh = true
  []

  # x-momentum, time
  [x_momentum_time]
    type = INSADMomentumTimeDerivative
    variable = vel_x
    use_displaced_mesh = true
  []

  # x-momentum, space
  [x_momentum_space]
    type = INSADMomentumBase
    variable = vel_x
    u = vel_x
    v = vel_y
    w = vel_z
    p = p
    component = 0
    use_displaced_mesh = true
  []

  # y-momentum, time
  [y_momentum_time]
    type = INSADMomentumTimeDerivative
    variable = vel_y
    use_displaced_mesh = true
  []

  # y-momentum, space
  [y_momentum_space]
    type = INSADMomentumBase
    variable = vel_y
    u = vel_x
    v = vel_y
    w = vel_z
    p = p
    component = 1
    use_displaced_mesh = true
  []

  # z-momentum, time
  [z_momentum_time]
    type = INSADMomentumTimeDerivative
    variable = vel_z
    use_displaced_mesh = true
  []

  # z-momentum, space
  [z_momentum_space]
    type = INSADMomentumBase
    variable = vel_z
    u = vel_x
    v = vel_y
    w = vel_z
    p = p
    component = 2
    use_displaced_mesh = true
  []

  # temperature
  [temperature_time]
    type = INSADTemperatureTimeDerivative
    variable = T
    use_displaced_mesh = true
  []

  [temperature_space]
    type = INSADTemperature
    variable = T
    u = vel_x
    v = vel_y
    w = vel_z
    p = p
    use_displaced_mesh = true
  []
[]

[BCs]
  [x_no_disp]
    type = DirichletBC
    variable = disp_x
    boundary = 'left right'
    value = 0
  []
  [y_no_disp]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom top'
    value = 0
  []
  [z_no_disp]
    type = DirichletBC
    variable = disp_z
    boundary = 'back'
    value = 0
  []

  [x_no_slip]
    type = DirichletBC
    variable = vel_x
    boundary = 'bottom left right top back'
    value = 0.0
  []

  [y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'bottom left right top back'
    value = 0.0
  []

  [z_no_slip]
    type = DirichletBC
    variable = vel_z
    boundary = 'bottom left right top back'
    value = 0.0
  []

  [T_cold]
    type = DirichletBC
    variable = T
    boundary = 'back'
    value = ${bottomtemp}
  []

  [pressure_pin]
    type = DirichletBC
    variable = p
    boundary = 'pinned_node'
    value = 0
  []
[]

[ADBCs]
  [radiation_flux]
    type = RadiationEnergyFluxBC
    variable = T
    boundary = 'front'
    ff_temp = ${bottomtemp}
    sb_constant = 'sb_constant'
    absorptivity = 'abs'
    use_displaced_mesh = true
  []

  [weld_flux]
    type = GaussianWeldEnergyFluxBC
    variable = T
    boundary = 'front'
    reff = 0.6
    F0 = '${fparse 2.546e9 / 10^mass_unit_exponent * 10^(3 * time_unit_exponent)}'
    R = '${fparse 1e-4 / 10^length_unit_exponent}'
    x_beam_coord = '${fparse 2e-4 / 10^length_unit_exponent} * cos(2 * pi / (50 * ${timestep}) * t)'
    y_beam_coord = '${fparse 2e-4 / 10^length_unit_exponent} * sin(2 * pi / (50 * ${timestep}) * t)'
    z_beam_coord = 0
    use_displaced_mesh = true
  []

  [vapor_recoil_x]
    type = VaporRecoilPressureMomentumFluxBC
    variable = vel_x
    boundary = 'front'
    component = 0
    use_displaced_mesh = true
  []

  [vapor_recoil_y]
    type = VaporRecoilPressureMomentumFluxBC
    variable = vel_y
    boundary = 'front'
    component = 1
    use_displaced_mesh = true
  []

  [vapor_recoil_z]
    type = VaporRecoilPressureMomentumFluxBC
    variable = vel_z
    boundary = 'front'
    component = 2
    use_displaced_mesh = true
  []

  [surface_x]
    type = SurfaceTensionBC
    variable = vel_x
    boundary = 'front'
    component = 0
    use_displaced_mesh = true
  []

  [surface_y]
    type = SurfaceTensionBC
    variable = vel_y
    boundary = 'front'
    component = 1
    use_displaced_mesh = true
  []

  [surface_z]
    type = SurfaceTensionBC
    variable = vel_z
    boundary = 'front'
    component = 2
    use_displaced_mesh = true
  []

  [displace_x_top]
    type = PenaltyDisplaceBoundaryBC
    boundary = 'front'
    variable = 'disp_x'
    vel_x = 'vel_x'
    disp_x = 'disp_x'
    vel_y = 'vel_y'
    disp_y = 'disp_y'
    vel_z = 'vel_z'
    disp_z = 'disp_z'
  []
  [displace_y_top]
    type = PenaltyDisplaceBoundaryBC
    boundary = 'front'
    variable = 'disp_y'
    vel_x = 'vel_x'
    disp_x = 'disp_x'
    vel_y = 'vel_y'
    disp_y = 'disp_y'
    vel_z = 'vel_z'
    disp_z = 'disp_z'
  []
  [displace_z_top]
    type = PenaltyDisplaceBoundaryBC
    boundary = 'front'
    variable = 'disp_z'
    vel_x = 'vel_x'
    disp_x = 'disp_x'
    vel_y = 'vel_y'
    disp_y = 'disp_y'
    vel_z = 'vel_z'
    disp_z = 'disp_z'
  []
[]

[ADMaterials]
  [kc_fits]
    type = DemonstrationPlantFits
    temperature = T
    beta = 1e7
    length_unit_exponent = ${length_unit_exponent}
    temperature_unit_exponent = ${temperature_unit_exponent}
    mass_unit_exponent = ${mass_unit_exponent}
    time_unit_exponent = ${time_unit_exponent}
  []
  [boundary]
    type = DemonstrationPlantFitsBoundary
    boundary = 'front'
    temperature = T
    use_displaced_mesh = true
    length_unit_exponent = ${length_unit_exponent}
    temperature_unit_exponent = ${temperature_unit_exponent}
    mass_unit_exponent = ${mass_unit_exponent}
    time_unit_exponent = ${time_unit_exponent}
  []
  [stress]
    type = PseudoSolidStress
    disp_x = disp_x
    disp_y = disp_y
    disp_z = disp_z
  []
[]

[Materials]
  [const]
    type = GenericConstantMaterial
    prop_names = 'abs sb_constant'
    prop_values = '1 ${fparse 5.67e-8 / 10^mass_unit_exponent * 10^(4 * temperature_unit_exponent) * 10^(3 * time_unit_exponent)}'
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
  end_time = ${endtime}
  dtmin = '${fparse 1e-8 / 10^time_unit_exponent}'
  petsc_options = '-snes_converged_reason -ksp_converged_reason -options_left -ksp_monitor_singular_value'
  petsc_options_iname = '-ksp_max_it -ksp_gmres_restart -pc_type -snes_max_funcs -sub_pc_factor_levels'
  petsc_options_value = '100       100          asm      1000000         1'

  line_search = 'none'
  nl_max_its = 12
  l_tol = 1e-2
  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 8
    dt = ${timestep}
    linear_iteration_ratio = 1e6
    growth_factor = 1.1
  []
[]

[Outputs]
  print_linear_residuals = false
  csv = true
  [exodus]
    type = Exodus
    output_material_properties = true
    show_material_properties = 'mu surface_term_curvature surface_term_gradient1 surface_term_gradient2'
  []
  # [./dofmap]
  #   type = DOFMap
  #   execute_on = 'timestep_end'
  # [../]
  checkpoint = true
[]

[Debug]
  show_var_residual_norms = true
[]

[Adaptivity]
  marker = combo
  max_h_level = 4
  initial_steps = 0

  [Indicators]
    [error_x]
      type = GradientJumpIndicator
      variable = vel_x
    []
    [error_y]
      type = GradientJumpIndicator
      variable = vel_y
    []
    [error_z]
      type = GradientJumpIndicator
      variable = vel_z
    []
    # [./error_p]
    #   type = GradientJumpIndicator
    #   variable = p
    # [../]
    [error_T]
      type = GradientJumpIndicator
      variable = T
    []
    [error_dispx]
      type = GradientJumpIndicator
      variable = disp_x
    []
    [error_dispy]
      type = GradientJumpIndicator
      variable = disp_y
    []
    [error_dispz]
      type = GradientJumpIndicator
      variable = disp_z
    []
  []

  [Markers]
    [errorfrac_x]
      type = ErrorFractionMarker
      refine = 0.8
      coarsen = 0.05
      indicator = error_x
    []
    [errorfrac_y]
      type = ErrorFractionMarker
      refine = 0.8
      coarsen = 0.05
      indicator = error_y
    []
    [errorfrac_z]
      type = ErrorFractionMarker
      refine = 0.8
      coarsen = 0.05
      indicator = error_z
    []
    # [./errorfrac_p]
    #   type = ErrorFractionMarker
    #   refine = 0.8
    #   coarsen = 0.05
    #   indicator = error_p
    # [../]
    [errorfrac_T]
      type = ErrorFractionMarker
      refine = 0.8
      coarsen = 0.05
      indicator = error_T
    []
    [errorfrac_dispx]
      type = ErrorFractionMarker
      refine = 0.8
      coarsen = 0.05
      indicator = error_dispx
    []
    [errorfrac_dispy]
      type = ErrorFractionMarker
      refine = 0.8
      coarsen = 0.05
      indicator = error_dispy
    []
    [errorfrac_dispz]
      type = ErrorFractionMarker
      refine = 0.8
      coarsen = 0.05
      indicator = error_dispz
    []
    [combo]
      type = ComboMarker
      markers = 'errorfrac_x errorfrac_y errorfrac_z errorfrac_T errorfrac_dispx errorfrac_dispy errorfrac_dispz'
    []
  []
[]

[Postprocessors]
  [num_dofs]
    type = NumDOFs
    system = 'NL'
  []
  [nl]
    type = NumNonlinearIterations
  []
  [tot_nl]
    type = CumulativeValuePostprocessor
    postprocessor = 'nl'
  []
  [linear]
    type = NumLinearIterations
  []
  [tot_linear]
    type = CumulativeValuePostprocessor
    postprocessor = 'linear'
  []
[]
