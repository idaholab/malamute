## Units in the input file: m-Pa-s-K

initial_temperature = 300 #roughly 600C where the pyrometer kicks in

[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = false
  order = SECOND
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = stepped_plunger_powder_2d.e
  []
  coord_type = RZ
  construct_side_list_from_node_list = true
  patch_update_strategy = iteration
  patch_size = 20
  # ghosting_patch_size = 5*patch_size
[]

[Problem]
  type = ReferenceResidualProblem
  reference_vector = 'ref'
  extra_tag_vectors = 'ref'
  group_variables = 'disp_x disp_y'
[]

# [Variables]
#   [temperature]
#     initial_condition = ${initial_temperature}
#   []
# []

[AuxVariables]
  [vonmises_stress]
    family = MONOMIAL
    order = FIRST
  []
  [density_va]
    initial_condition = 3106.2 ##5010.0*(1-${initial_porosity}) #in kg/m^3
  []
  [temperature]
    order = FIRST
    family = LAGRANGE
    initial_condition = ${initial_temperature}
  []
[]

[Physics]
  [SolidMechanics/QuasiStatic]
    [graphite]
      strain = FINITE
      add_variables = true
      use_automatic_differentiation = true
      generate_output = 'strain_xx strain_xy strain_yy strain_zz stress_xx stress_xy stress_yy stress_zz'
      extra_vector_tags = 'ref'
      eigenstrain_names = 'graphite_thermal_expansion'
      block = 'upper_plunger lower_plunger die_wall'
    []
    [yttria]
      strain = FINITE
      add_variables = true
      use_automatic_differentiation = true
      generate_output = 'plastic_strain_yy strain_xx strain_xy strain_yy strain_zz stress_xx stress_xy stress_yy stress_zz'
      extra_vector_tags = 'ref'
      eigenstrain_names = 'yttria_thermal_expansion'
      block = 'powder_compact'
    []
  []
[]

[AuxKernels]
  [vonmises_stress]
    type = ADRankTwoScalarAux
    variable = vonmises_stress
    rank_two_tensor = stress
    scalar_type = VonMisesStress
  []
  [temp_aux]
    type = FunctionAux
    variable = temperature
    function = temp_hist
  []
[]

[BCs]
  [centerline_no_dispx]
    type = ADDirichletBC
    preset = true
    variable = disp_x
    value = 0
    boundary = 'centerline_powder_compact centerline_upper_plunger centerline_lower_plunger'
  []
  [die_no_disp]
    type = ADDirichletBC
    preset = true
    variable = disp_y
    value = 0
    boundary = 'centerpoint_outer_die_wall'
  []
  [bottom_disp]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = 'bottom_lower_plunger'
    function = 'if(t<5.0, (125.0e-6/5.0)*t, 125.0e-6)'
  []
  [top_disp]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = 'top_upper_plunger'
    function = 'if(t<5.0, (-125.0e-6/5.0)*t, -125.0e-6)'
  []
[]

[Functions]
  [yield]
    type = PiecewiseLinear
    x = '100  600  700  800  900  5000' #temperature
    y = '15e6 15e6 14e6 13e6 10e6 10e6' #yield stress
  []
  [temp_hist]
    type = PiecewiseLinear
    x = '0   5   10' #time
    y = '300 600 900' #temperature
  []
[]

[Contact]
  [upper_plunger_powder_mechanical]
    primary = bottom_upper_plunger
    secondary = top_powder_compact
    formulation = penalty
    model = frictionless
    penalty = 1e14 #1e4 is good in the mm-MPa system
    normal_smoothing_distance = 0.1 #was 0.1 in mm-MPa system
    normalize_penalty = true
  []
  [upper_plunger_die_mechanical]
    secondary = outer_upper_plunger
    primary = inner_die_wall
    formulation = penalty
    model = frictionless
    penalty = 1e14 #isotropic yttria block takes 1e12
    normal_smoothing_distance = 0.1
    normalize_penalty = true
  []
  [powder_die_mechanical]
    primary = inner_die_wall
    secondary = outer_powder_compact
    formulation = penalty
    model = frictionless
    penalty = 1e14 #isotropic yttria block takes 1e12
    normal_smoothing_distance = 0.1
    normalize_penalty = true
  []
  [lower_plunger_die_mechanical]
    primary = inner_die_wall
    secondary = outer_lower_plunger
    formulation = penalty
    model = frictionless
    penalty = 1e14 #isotropic yttria block takes 1e12
    normal_smoothing_distance = 0.1
    normalize_penalty = true
  []
  [powder_bottom_plunger_mechanical]
    secondary = bottom_powder_compact
    primary = top_lower_plunger
    formulation = penalty
    model = frictionless
    penalty = 1e14 #isotropic takes 1e12
    normal_smoothing_distance = 0.1
    normalize_penalty = true
  []
[]

[Materials]
  [graphite_elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 1.08e10 #in Pa, 10.8 GPa, Cincotti
    poissons_ratio = 0.33
    block = 'upper_plunger lower_plunger die_wall'
  []
  [graphite_stress]
    type = ADComputeFiniteStrainElasticStress
    block = 'upper_plunger lower_plunger die_wall'
  []
  [graphite_thermal_expansion]
    type = ADGraphiteThermalExpansionEigenstrain
    eigenstrain_name = graphite_thermal_expansion
    stress_free_temperature = 300
    temperature = temperature
    block = 'upper_plunger lower_plunger die_wall'
  []
  [graphite_density]
    type = ADGenericConstantMaterial
    prop_names = 'graphite_density'
    prop_values = 1.750e3 #in kg/m^3 from Cincotti et al 2007, Table 2, doi:10.1002/aic
    block = 'upper_plunger lower_plunger die_wall'
  []

  [yttria_elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    # youngs_modulus = 1.16e11 #in Pa for fully dense part
    youngs_modulus = 1.38e10 #in Pa assuming 62% initial density and theoretical coeff. from Phani and Niyogi (1987)
    poissons_ratio = 0.36
    block = powder_compact
  []
  [yttria_stress]
    type = ADComputeMultipleInelasticStress
    block = powder_compact
    inelastic_models = yttria_plastic_model
  []
  [yttria_plastic_model]
    type = ADIsotropicPlasticityStressUpdate
    block = powder_compact
    hardening_constant = 0.1e10
    # yield_stress = 15e6
    yield_stress_function = yield
    temperature = temperature
    outputs = all
    # relative_tolerance = 1e-20
    # absolute_tolerance = 1e-8
    # max_inelastic_increment = 0.000001

  []
  [yttria_thermal_expansion]
    type = ADComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 9.3e-6 # from https://doi.org/10.1111/j.1151-2916.1957.tb12619.x
    eigenstrain_name = yttria_thermal_expansion
    stress_free_temperature = 300
    temperature = temperature
  []
  [yttria_density]
    type = ADParsedMaterial
    property_name = 'yttria_density'
    coupled_variables = 'density_va'
    expression = 'density_va'
    # output_properties = yttria_density
    # outputs = 'csv exodus'
    block = powder_compact
  []
[]

[Dampers]
  [disp_x_damp]
    type = ElementJacobianDamper
    # max_increment = 2.0e-4
    use_displaced_mesh = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  automatic_scaling = true
  line_search = 'none'
  # compute_scaling_once = false

  # force running options
  # petsc_options_iname = '-pc_type -snes_linesearch_type -pc_factor_shift_type -pc_factor_shift_amount'
  # petsc_options_value = 'lu       basic                 NONZERO               1e-15'

  # #mechanical contact options
  # petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = ' lu       superlu_dist'
  petsc_options = '-snes_converged_reason -ksp_converged_reason'

  nl_forced_its = 1
  nl_rel_tol = 2e-5 #was 1e-10, for temperature only
  nl_abs_tol = 2e-12 #was 1e-10, before that 1e-12
  nl_max_its = 20
  l_max_its = 50
  dtmin = 1.0e-4
  dtmax = .4
  dt = 0.4

  end_time = 10 #900 #15 minutes, rule of thumb from Dennis is 10 minutes
  [Quadrature]
    order = FIFTH
    side_order = SEVENTH
  []
  # [TimeStepper]
  #   type = IterationAdaptiveDT
  #   dt = 0.1
  #   optimal_iterations = 8
  #   iteration_window = 2
  # []
[]

[Postprocessors]
  [powder_strain_yy]
    type = ElementAverageValue
    variable = strain_yy
    block = powder_compact
  []
  [powder_stress_yy]
    type = ElementAverageValue
    variable = stress_yy
    block = powder_compact
  []
  [powder_vonmises_stress]
    type = ElementAverageValue
    variable = vonmises_stress
    block = powder_compact
  []
  [powder_plastic_strain_yy]
    type = ElementAverageValue
    variable = plastic_strain_yy
    block = powder_compact
  []
  [powder_max_strain_yy]
    type = ElementExtremeValue
    variable = strain_yy
    block = powder_compact
  []
  [powder_max_stress_yy]
    type = ElementExtremeValue
    variable = stress_yy
    block = powder_compact
  []
  [powder_max_vonmises_stress]
    type = ElementExtremeValue
    variable = vonmises_stress
    block = powder_compact
  []
  [powder_max_plastic_strain_yy]
    type = ElementExtremeValue
    variable = plastic_strain_yy
    block = powder_compact
  []
  [powder_temperature_pp]
    type = AverageNodalVariableValue
    variable = temperature
    block = powder_compact
  []

  [plunger_strain_yy]
    type = ElementAverageValue
    variable = strain_yy
    block = 'upper_plunger lower_plunger'
  []
  [plunger_stress_yy]
    type = ElementAverageValue
    variable = stress_yy
    block = 'upper_plunger lower_plunger'
  []
  [plunger_vonmises_stress]
    type = ElementAverageValue
    variable = vonmises_stress
    block = 'upper_plunger lower_plunger'
  []
[]

[Outputs]
  csv = true
  exodus = true
  perf_graph = true
  # [ckpt]
  #   type =Checkpoint
  #   time_step_interval = 1
  #   num_files = 2
  # []
[]
