# unit of length (mm), time (ms)

T_room = 300
T_melt = 1700

dt = 200

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  volumetric_locking_correction = true
[]

[Problem]
  material_coverage_check = false
[]

[Mesh]
  [mesh]
    type = GeneratedMeshGenerator
    dim = 3
    xmin = -4.5
    xmax = 4.5
    ymin = -4.5
    ymax = 4.5
    zmin = 0
    zmax = 3.3
    nx = 30
    ny = 30
    nz = 11
  []
  [add_set1]
    type = SubdomainBoundingBoxGenerator
    input = mesh
    block_id = 3
    bottom_left = '-50 -50 0'
    top_right = '50 50 0.9'
  []
  [add_set2]
    type = SubdomainBoundingBoxGenerator
    input = add_set1
    block_id = 1
    bottom_left = '-50 -50 0.9'
    top_right = '50 50 3.3'
  []

  [add_set3]
    type = GeneratedMeshGenerator
    dim = 3
    xmax = 0.001
    ymax = 0.001
    zmin = -0.001
    subdomain_ids = 2
  []
  [moving_boundary]
    type = SideSetsAroundSubdomainGenerator
    input = add_set3
    block = 2
    new_boundary = 'moving_boundary'
  []

  [cmbn]
    type = CombinerGenerator
    inputs = 'add_set2 moving_boundary'
  []

  skip_partitioning = true
[]

[Variables]
  [disp_x]
    block = '1 2 3'
  []
  [disp_y]
    block = '1 2 3'
  []
  [disp_z]
    block = '1 2 3'
  []
[]

[AuxVariables]
  [temp_aux]
    order = FIRST
    family = LAGRANGE
    block = '1 2 3'
  []
  [von_mises]
    order = CONSTANT
    family = MONOMIAL
    block = '2 3'
  []
  [plastic_strain_eff]
    order = CONSTANT
    family = MONOMIAL
    block = '2 3'
  []
  [x_coord]
    order = FIRST
    family = LAGRANGE
  []
  [y_coord]
    order = FIRST
    family = LAGRANGE
  []
  [z_coord]
    order = FIRST
    family = LAGRANGE
  []
[]

# this is to avoid drastic mesh distortion
[Kernels]
  [null_x]
    type = ADDiffusion
    variable = 'disp_x'
    block = 1
  []
  [null_y]
    type = ADDiffusion
    variable = 'disp_y'
    block = 1
  []
  [null_z]
    type = ADDiffusion
    variable = 'disp_z'
    block = 1
  []
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      strain = FINITE
      incremental = true
      generate_output = 'stress_xx stress_yy stress_zz stress_xy stress_yz stress_xz strain_yy strain_xx '
                        'strain_zz strain_xy strain_xz strain_yz'
      use_automatic_differentiation = true
      [product]
        block = '2'
        eigenstrain_names = 'thermal_eigenstrain_product'
        use_automatic_differentiation = true
      []
      [substrate]
        block = '3'
        eigenstrain_names = 'thermal_eigenstrain_substrate'
        use_automatic_differentiation = true
      []
    []
  []
[]

[AuxKernels]
  [von_mises_kernel]
    type = ADRankTwoScalarAux
    variable = von_mises
    rank_two_tensor = stress
    execute_on = timestep_end
    scalar_type = VonMisesStress
    block = '2 3'
  []
[]

[BCs]
  [ux_bottom_fix]
    type = ADDirichletBC
    variable = disp_x
    boundary = 'back'
    value = 0.0
  []
  [uy_bottom_fix]
    type = ADDirichletBC
    variable = disp_y
    boundary = 'back'
    value = 0.0
  []
  [uz_bottom_fix]
    type = ADDirichletBC
    variable = disp_z
    boundary = 'back'
    value = 0.0
  []
[]

[Materials]
  [E]
    type = ADPiecewiseLinearInterpolationMaterial
    x = '0 294.994  1671.48  1721.77 1e7'
    y = '201.232e3 201.232e3 80.0821e3 6.16016e3 6.16016e3' #MPa # 10^9 Pa = 10^9 kg/m/s^2 = kg/mm/ms^2
    property = youngs_modulus
    variable = temp_aux
    extrapolation = false
    block = '2 3'
  []
  [nu]
    type = ADPiecewiseLinearInterpolationMaterial
    x = '0 294.994 1669.62 1721.77 1e7'
    y = '0.246407 0.246407   0.36961  0.36961 0.36961' #''0.513347 0.513347'
    property = poissons_ratio
    variable = temp_aux
    extrapolation = false
    block = '2 3'
  []
  [elasticity_tensor]
    type = ADComputeVariableIsotropicElasticityTensor
    youngs_modulus = youngs_modulus
    poissons_ratio = poissons_ratio
    block = '2 3'
  []

  [thermal_expansion_strain_product]
    type = ADComputeThermalExpansionEigenstrain
    stress_free_temperature = ${T_melt}
    thermal_expansion_coeff = 1.72e-6
    temperature = temp_aux
    eigenstrain_name = thermal_eigenstrain_product
    block = '2'
  []
  [thermal_expansion_strain_substrate]
    type = ADComputeThermalExpansionEigenstrain
    stress_free_temperature = ${T_room}
    thermal_expansion_coeff = 1.72e-6
    temperature = temp_aux
    eigenstrain_name = thermal_eigenstrain_substrate
    block = '3'
  []

  [radial_return_stress]
    type = ADComputeMultipleInelasticStress
    inelastic_models = 'power_law_hardening'
    block = '2 3'
  []

  [power_law_hardening]
    type = ADIsotropicPowerLawHardeningStressUpdate
    strength_coefficient = 847 #K
    strain_hardening_exponent = 0.06 #n
    relative_tolerance = 1e-6
    absolute_tolerance = 1e-8
    temperature = temp_aux
    block = '2 3'
  []
[]

[UserObjects]
  [activated_elem_uo_beam]
    type = CoupledVarThresholdElementSubdomainModifier
    execute_on = 'TIMESTEP_BEGIN'
    coupled_var = temp_aux
    block = 1
    subdomain_id = 2
    criterion_type = ABOVE
    threshold = ${T_melt}
    moving_boundary_name = 'moving_boundary'
    apply_initial_conditions = false
  []
[]

[Adaptivity]
  marker = marker
  initial_marker = marker
  max_h_level = 3
  [Indicators]
    [indicator]
      type = GradientJumpIndicator
      variable = temp_aux
    []
  []
  [Markers]
    [marker]
      type = ErrorFractionMarker
      indicator = indicator
      coarsen = 0 # coarsening is pending MOOSE PR #23078 being merged
      refine = 0.5
    []
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'

  petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_package -pc_factor_shift_type '
                        '-pc_factor_shift_amount'
  petsc_options_value = 'preonly lu       superlu_dist NONZERO 1e-10'

  line_search = 'none'

  l_max_its = 100
  nl_max_its = 20
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  start_time = 0.0
  end_time = 57036
  dt = ${dt} # ms
  dtmin = 1e-6

  error_on_dtmin = false
[]

[Outputs]
  file_base = 'output/Mechanical'
  csv = true
  [exodus]
    type = Exodus
    file_base = 'output/Exodus/Mechanical'
    time_step_interval = 1
  []
[]

[Postprocessors]
  [max_von_mises_stress]
    type = ElementExtremeValue
    variable = von_mises
    value_type = max
    block = '2'
  []
  [min_von_mises_stress]
    type = ElementExtremeValue
    variable = von_mises
    value_type = min
    block = '2'
  []
[]

[MultiApps]
  [thermo_mech]
    type = TransientMultiApp
    positions = '0.0 0.0 0.0'
    input_files = sub_app_thermal.i

    catch_up = true
    max_catch_up_steps = 10
    keep_solution_during_restore = true
    execute_on = 'TIMESTEP_END'
    cli_args = 'dt=${dt};T_room=${T_room};T_melt=${T_melt}'
  []
[]

[Transfers]
  [from_thermal]
    type = MultiAppGeneralFieldNearestLocationTransfer
    from_multi_app = thermo_mech
    execute_on = 'TIMESTEP_END'
    source_variable = 'temp'
    variable = 'temp_aux'
  []
[]
