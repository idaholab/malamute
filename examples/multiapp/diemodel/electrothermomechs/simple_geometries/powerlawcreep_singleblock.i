## Units in the input file: m-Pa-s-K

#initial_porosity = 0.38
initial_temperature=300 #roughly 600C where the pyrometer kicks in

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
    xmax = 0.0005
    ymin = 0.0005
    ymax = 0.001
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
    old_block_id = '1'
    new_block_name = 'powder_compact'
  []
  [inner_centerpoint]
    type = BoundingBoxNodeSetGenerator
    input = block_rename
    bottom_left = '0.0    0.00074 0'
    top_right = '0.25e-5 0.000755 0'
    new_boundary = 'centerpoint'
  []
  # [outer_centerpoint]
  #   type = BoundingBoxNodeSetGenerator
  #   input = inner_centerpoint
  #   bottom_left = '0.00049    0.00074 0'
  #   top_right = '5.25e-5 0.000755 0'
  #   new_boundary = 'outer_centerpoint'
  # []
  patch_update_strategy = iteration
  patch_size = 10
[]

[Problem]
  coord_type = RZ
  type = ReferenceResidualProblem
  reference_vector = 'ref'
  extra_tag_vectors = 'ref'
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

[Modules]
  [TensorMechanics/Master]
    [graphite]
      strain = FINITE
      add_variables = true
      use_automatic_differentiation = true
      generate_output = 'strain_xx strain_xy strain_yy strain_zz stress_xx stress_xy stress_yy stress_zz'
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
    type = ConductivityLaplacian
    variable = electric_potential
    conductivity_coefficient = electrical_conductivity
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
    args = 'temperature'
    constant_names = 'boltzmann epsilon temperature_farfield'
    constant_expressions = '5.67e-8 0.85 300.0' #roughly room temperature, which is probably too cold
    function = '-boltzmann*epsilon*(temperature^4-temperature_farfield^4)'
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
  [fixed_in_y]
    type = ADDirichletBC
    preset = true
    variable = disp_y
    value = 0
    boundary = 'centerpoint'
  []
  [bottom_pressure_ydirection]
    type = ADPressure
    variable = disp_y
    boundary = 'powder_compact_bottom'
    function = 20.7e6 #'if(t<1, 20.7e6*t, 20.7e6)'
    component = 1
  []
  [top_pressure_ydirection]
    type = ADPressure
    variable = disp_y
    boundary = 'powder_compact_top'
    function = 20.7e6 #'if(t<1, 20.7e6*t, 20.7e6)'
    component = 1
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

# [Functions]
#   [graphite_thermal_conductivity_fcn]
#     type = ParsedFunction
#     value = 29.0 #'-4.418e-12*t^4+2.904e-8*t^3-4.688e-5*t^2-0.0316*t+119.659'
#   []
#   # [yttria_thermal_conductivity_fcn] #from the multiapp
#   #   type = ParsedFunction
#   #   value = '3214.46/(t-147.73)'
#   # []
#   # [harmonic_mean_thermal_conductivity]
#   #   type = ParsedFunction
#   #   value = '2*(-4.418e-12*t^4+2.904e-8*t^3-4.688e-5*t^2-0.0316*t+119.659)*(3214.46/(t-147.73))/((-4.418e-12*t^4+2.904e-8*t^3-4.688e-5*t^2-0.0316*t+119.659)+(3214.46/(t-147.73)))'
#   #   # vars = 'k_graphite k_yttria'
#   #   # vals = 'graphite_thermal_conductivity_fcn yttria_thermal_conductivity_fcn'
#   # []
#
#   [graphite_electrical_conductivity_fcn]
#     type = ParsedFunction
#     value = 1.1e5 #'1.0/(-2.705e-15*t^3+1.263e-11*t^2-1.836e-8*t+1.813e-5)'
#   []
#   # [yttria_electrical_conductivity_fcn]
#   #   type = ParsedFunction
#   #   # vars = porosity
#   #   # vals = initial_porosity
#   #   value = '(1-0.62)*2.0025e4*exp(-1.61/8.617343e-5/t)'
#   # []
#   # [harmonic_mean_electrical_conductivity]
#   #   type = ParsedFunction
#   #   value = '2*(1.0/(-2.705e-15*t^3+1.263e-11*t^2-1.836e-8*t+1.813e-5))*((1)*2.0025e4*exp(-1.61/8.617343e-5/t))/((1.0/(-2.705e-15*t^3+1.263e-11*t^2-1.836e-8*t+1.813e-5))+((1)*2.0025e4*exp(-1.61/8.617343e-5/t)))'
#   #   # vars = 'k_graphite k_yttria'
#   #   # vals = 'graphite_thermal_conductivity_fcn yttria_thermal_conductivity_fcn'
#   # []
# []

[Materials]
  [yttria_elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    # youngs_modulus = 1.16e11 #in Pa for fully dense part
    youngs_modulus = 1.38e10 #in Pa assuming 62% initial density and theoretical coeff. from Phani and Niyogi (1987)
    poissons_ratio = 0.36
  []
  [yttria_stress]
    type = ADComputeMultipleInelasticStress
    inelastic_models = yttria_creep_model
  []
  [yttria_creep_model]
    type = ADPowerLawCreepStressUpdate
    coefficient = 3.75e-7 #1e-15
    n_exponent = 0.714 #from Al's work
    activation_energy = 0.0
  []
  [yttria_thermal_conductivity]
    type = ADParsedMaterial
    args = 'temperature'
    function = '3214.46 / (temperature - 147.73)' #in W/(m-K) #Given from Larry's curve fitting, data from Klein and Croft, JAP, v. 38, p. 1603 and UC report "For Computer Heat Conduction Calculations - A compilation of thermal properties data" by A.L. Edwards, UCRL-50589 (1969)
    # args = 'thermal_conductivity_aeh'
    # function = 'thermal_conductivity_aeh' #in W/(m-K) directly, for now
    f_name = 'thermal_conductivity'
    output_properties = thermal_conductivity
    outputs = 'csv exodus'
  []
  [thermal_expansion]
    type = ADComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 9.3e-6  # from https://doi.org/10.1111/j.1151-2916.1957.tb12619.x
    eigenstrain_name = thermal_expansion
    stress_free_temperature = 300
    temperature = temperature
  []
  [yttria_specific_heat_capacity]
    type = ADParsedMaterial
    f_name = heat_capacity
    args = 'specific_heat_capacity_va'
    function = 'specific_heat_capacity_va' #in J/(K-kg)
    # output_properties = yttria_specific_heat_capacity
    # outputs = 'csv exodus'
  []
  [yttria_density]
    type = ADParsedMaterial
    f_name = 'yttria_density'
    args = 'density_va'
    function = 'density_va'
    # output_properties = yttria_density
    # outputs = 'csv exodus'
  []
  [electrical_conductivity]
    type = ADParsedMaterial
  #   args = 'sigma_aeh'
  #   function = 'sigma_aeh*1.602e8' #converts to units of J/(V^2-m-s)
    f_name = 'electrical_conductivity'
    output_properties = electrical_conductivity
    outputs = 'exodus csv'
    # type = ADDerivativeParsedMaterial
    # f_name = electrical_conductivity
    args = 'temperature'
    constant_names =       'Q_elec  kB            prefactor_solid  initial_porosity'
    constant_expressions = '1.61    8.617343e-5        1.25e-4           0.38'
    function = '(1-initial_porosity) * prefactor_solid * exp(-Q_elec/kB/temperature) * 1.602e8' # in eV/(nV^2 s nm) per chat with Larry, last term converts to units of J/(V^2-m-s)
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

  end_time = 50
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.05
    optimal_iterations = 8
    iteration_window = 2
  []
[]

[Postprocessors]
  [stress_xx]
    type = ElementAverageValue
    variable = stress_xx
  []
  [strain_xx]
    type = ElementAverageValue
    variable = strain_xx
  []
  [stress_yy]
    type = ElementAverageValue
    variable = stress_yy
  []
  [strain_yy]
    type = ElementAverageValue
    variable = strain_yy
  []
  [vonmises_stress]
    type = ElementAverageValue
    variable = vonmises_stress
  []
[]


[Outputs]
  csv = true
  exodus = true
  perf_graph = true
[]
