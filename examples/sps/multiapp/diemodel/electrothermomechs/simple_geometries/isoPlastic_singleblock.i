## Units in the input file: m-Pa-s-K

#initial_porosity = 0.38
initial_temperature = 600 #roughly 600C where the pyrometer kicks in

[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = false
  order = SECOND
[]

[Mesh]
  [top_square]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 20
    ny = 20
    xmax = 0.01
    ymin = 0.015
    ymax = 0.023
    boundary_name_prefix = powder_compact
    elem_type = QUAD8
  []
  [top_square_block]
    type = SubdomainIDGenerator
    input = top_square
    subdomain_id = 1
  []
  [two_blocks]
    type = MeshCollectionGenerator
    inputs = 'top_square_block'
  []
  [block_rename]
    type = RenameBlockGenerator
    input = two_blocks
    old_block = '1'
    new_block = 'powder_compact'
  []
  coord_type = RZ
  patch_update_strategy = iteration
  patch_size = 10
[]

[Problem]
  type = ReferenceResidualProblem
  reference_vector = 'ref'
  extra_tag_vectors = 'ref'
  group_variables = 'disp_x disp_y'
[]

[Variables]
  [temperature]
    initial_condition = ${initial_temperature}
  []
  [electric_potential]
  []
[]

[AuxVariables]
  [vonmises_stress]
    family = MONOMIAL
    order = FIRST
  []

  # [thermal_conductivity_aeh]
  #   initial_condition = 0.4
  # []
  [specific_heat_capacity_va]
    initial_condition = 842.2 # at 1500K #568.73 at 1000K #447.281 # at 293K
  []
  [density_va]
    initial_condition = 3106.2 ##5010.0*(1-${initial_porosity}) #in kg/m^3
  []
  [heat_transfer_radiation]
  []
  [current_density_J]
    family = NEDELEC_ONE
    order = FIRST
  []
[]

[Physics]
  [SolidMechanics/QuasiStatic]
    [graphite]
      strain = FINITE
      add_variables = true
      use_automatic_differentiation = true
      generate_output = 'plastic_strain_yy strain_xx strain_xy strain_yy strain_zz stress_xx stress_xy stress_yy stress_zz'
      extra_vector_tags = 'ref'
      eigenstrain_names = 'thermal_expansion'
    []
  []
[]

[Kernels]
  [HeatDiff_graphite]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = thermal_conductivity #use parsed material property, hope it works
    extra_vector_tags = 'ref'
  []
  [HeatTdot_graphite]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = heat_capacity #use parsed material property
    density_name = yttria_density
    extra_vector_tags = 'ref'
  []
  [JouleHeating_graphite]
    type = ADJouleHeatingSource
    variable = temperature
    elec = electric_potential
    electrical_conductivity = electrical_conductivity
    use_displaced_mesh = true
    extra_vector_tags = 'ref'
  []
  [electric_graphite]
    type = ADMatDiffusion
    variable = electric_potential
    diffusivity = electrical_conductivity
    extra_vector_tags = 'ref'
  []
[]

[AuxKernels]
  [vonmises_stress]
    type = ADRankTwoScalarAux
    variable = vonmises_stress
    rank_two_tensor = stress
    scalar_type = VonMisesStress
  []

  [heat_transfer_radiation]
    type = ParsedAux
    variable = heat_transfer_radiation
    boundary = 'powder_compact_right'
    coupled_variables = 'temperature'
    constant_names = 'boltzmann epsilon temperature_farfield'
    constant_expressions = '5.67e-8 0.85 300.0' #roughly room temperature, which is probably too cold
    expression = '-boltzmann*epsilon*(temperature^4-temperature_farfield^4)'
  []
  [current_density_J]
    type = ADCurrentDensity
    variable = current_density_J
    potential = electric_potential
  []
[]

[BCs]
  [centerline_no_dispx]
    type = ADDirichletBC
    preset = true
    variable = disp_x
    value = 0
    boundary = 'powder_compact_left'
  []
  [top_disp]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = 'powder_compact_top'
    function = 'if(t<5.0, (-50.0e-6/5.0)*t, -50.0e-6)'
  []

  [bottom_no_disp]
    type = ADDirichletBC
    preset = true
    variable = disp_y
    value = 0
    boundary = 'powder_compact_bottom'
  []

  [external_surface]
    type = CoupledVarNeumannBC
    boundary = 'powder_compact_right'
    variable = temperature
    v = heat_transfer_radiation
  []

  [electric_top]
    type = ADFunctionDirichletBC
    variable = electric_potential
    boundary = 'powder_compact_top'
    function = 'if(t<20.0, 4.0e-3*t, 0.08)'
    # value = 1.5 #2.5 #'3.5' ## V #+1.0e-6*t'
  []
  [electric_bottom]
    type = ADDirichletBC
    variable = electric_potential
    boundary = 'powder_compact_bottom'
    value = 0.0 #1.0 #0.0
  []
[]

[Functions]
  [yield]
    type = PiecewiseLinear
    x = '100  300  400  500  600  5000' #temperature
    y = '15e6 15e6 14e6 13e6 10e6 10e6' #yield stress
  []
  [temp_hist]
    type = PiecewiseLinear
    x = '0   5   10' #time
    y = '300 300 600' #temperature
  []
[]

[Materials]
  [yttria_elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    # youngs_modulus = 1.16e11 #in Pa for fully dense part
    youngs_modulus = 1.38e10 #in Pa assuming 62% initial density and theoretical coeff. from Phani and Niyogi (1987)
    poissons_ratio = 0.36
  []
  [yttria_stress]
    type = ADComputeMultipleInelasticStress
    inelastic_models = yttria_plastic_model
  []
  [yttria_plastic_model]
    type = ADIsotropicPlasticityStressUpdate
    yield_stress_function = yield
    hardening_constant = 0.1e10
    temperature = temperature
    outputs = all
    # max_inelastic_increment = 0.000001
  []
  [yttria_thermal_conductivity]
    type = ADParsedMaterial
    coupled_variables = 'temperature'
    expression = '3214.46 / (temperature - 147.73)' #in W/(m-K) #Given from Larry's curve fitting, data from Klein and Croft, JAP, v. 38, p. 1603 and UC report "For Computer Heat Conduction Calculations - A compilation of thermal properties data" by A.L. Edwards, UCRL-50589 (1969)
    # coupled_variables = 'thermal_conductivity_aeh'
    # expression = 'thermal_conductivity_aeh' #in W/(m-K) directly, for now
    property_name = 'thermal_conductivity'
    output_properties = thermal_conductivity
    outputs = 'csv exodus'
  []
  [thermal_expansion]
    type = ADComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 9.3e-6 # from https://doi.org/10.1111/j.1151-2916.1957.tb12619.x
    eigenstrain_name = thermal_expansion
    stress_free_temperature = ${initial_temperature} #300
    temperature = temperature
  []
  [yttria_specific_heat_capacity]
    type = ADParsedMaterial
    property_name = heat_capacity
    coupled_variables = 'specific_heat_capacity_va'
    expression = 'specific_heat_capacity_va' #in J/(K-kg)
    # output_properties = yttria_specific_heat_capacity
    # outputs = 'csv exodus'
  []
  [yttria_density]
    type = ADParsedMaterial
    property_name = 'yttria_density'
    coupled_variables = 'density_va'
    expression = 'density_va'
    # output_properties = yttria_density
    # outputs = 'csv exodus'
  []
  [electrical_conductivity]
    type = ADParsedMaterial
    #   coupled_variables = 'sigma_aeh'
    #   expression = 'sigma_aeh*1.602e8' #converts to units of J/(V^2-m-s)
    property_name = 'electrical_conductivity'
    output_properties = electrical_conductivity
    outputs = 'exodus csv'
    # type = ADDerivativeParsedMaterial
    # property_name = electrical_conductivity
    coupled_variables = 'temperature'
    constant_names = 'Q_elec  kB            prefactor_solid  initial_porosity'
    constant_expressions = '1.61    8.617343e-5        1.25e-4           0.38'
    expression = '(1-initial_porosity) * prefactor_solid * exp(-Q_elec/kB/temperature) * 1.602e8' # in eV/(nV^2 s nm) per chat with Larry, last term converts to units of J/(V^2-m-s)
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  automatic_scaling = true
  line_search = 'none'
  # compute_scaling_once = false

  # petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = ' lu       superlu_dist'

  nl_rel_tol = 1e-4 #was 1e-10, for temperature only
  nl_abs_tol = 2e-12 #was 1e-10, before that 1e-12
  nl_max_its = 20
  l_max_its = 50
  dtmin = 1.0e-3
  dtmax = .05
  dt = .05
  end_time = 5
  # [TimeStepper]
  #   type = IterationAdaptiveDT
  #   dt = 0.025
  #   optimal_iterations = 8
  #   iteration_window = 2
  # []
[]

[Postprocessors]
  [strain_yy]
    type = ElementAverageValue
    variable = strain_yy
  []
  [stress_yy]
    type = ElementAverageValue
    variable = stress_yy
  []
  [vonmises_stress]
    type = ElementAverageValue
    variable = vonmises_stress
  []
  [plastic_strain_yy]
    type = ElementAverageValue
    variable = plastic_strain_yy
  []
  [temperature_pp]
    type = AverageNodalVariableValue
    variable = temperature
  []
[]

[Outputs]
  csv = true
  exodus = true
  perf_graph = true
[]
