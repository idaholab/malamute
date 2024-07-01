T_room = 300
T_ambient = 300
T_melt = 1700

power = 0.3 # 300W = kg*m^2/s^3 = 300e-3 kg*mm^2/ms^3
r = 0.3 # 300 um = 300e-3 mm
dt = 20

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
  # [middle]
  #   type = SideSetsAroundSubdomainGenerator
  #   input = moving_boundary
  #   block = 3
  #   new_boundary = 'middle'
  #   normal = '0 0 1'
  # []

  [cmbn]
    type = CombinerGenerator
    inputs = 'add_set2 moving_boundary'
  []

  skip_partitioning = true
[]

[Problem]
  material_coverage_check = false
[]

[Variables]
  [temp]
    block = '1 2 3'
  []
[]

[ICs]
  [temp_substrate]
    type = ConstantIC
    variable = temp
    value = ${T_room}
    block = '1 3'
  []
  [temp_product]
    type = FunctionIC
    variable = temp
    function = temp_ic
    block = '2'
  []
[]

[AuxVariables]
  [processor_id]
    order = CONSTANT
    family = MONOMIAL
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

[Kernels]
  [time]
    type = ADHeatConductionTimeDerivative
    variable = temp
  []
  [heat_conduc]
    type = ADHeatConduction
    variable = temp
    thermal_conductivity = thermal_conductivity
  []
  [heatsource]
    type = ADMatHeatSource
    material_property = volumetric_heat
    variable = temp
    scalar = 1
  []
[]

[AuxKernels]
  [processor_id_aux]
    type = ProcessorIDAux
    variable = processor_id
    execute_on = timestep_begin
  []
  [x_coord]
    type = FunctionAux
    function = x_coord
    variable = x_coord
  []
  [y_coord]
    type = FunctionAux
    function = y_coord
    variable = y_coord
  []
  [z_coord]
    type = FunctionAux
    function = z_coord
    variable = z_coord
  []
[]

[BCs]
  [bottom_temp]
    type = ADDirichletBC
    variable = temp
    boundary = 'back'
    value = ${T_room}
  []
  [convective]
    type = ADConvectiveHeatFluxBC
    variable = temp
    boundary = 'bottom front left right top'
    heat_transfer_coefficient = 2e-5
    T_infinity = ${T_ambient}
  []
[]

[Functions]
  [heat_source_x]
    type = ParsedFunction
    expression = 2.0*cos(2.0*pi/c*t)
    symbol_names = 'c'
    symbol_values = '1257'
  []
  [heat_source_y]
    type = ParsedFunction
    expression = 2.0*sin(2.0*pi/c*t)
    symbol_names = 'c'
    symbol_values = '1257'
  []
  [heat_source_z]
    type = PiecewiseConstant
    xy_data = '0 0.9
               1257 1.35
               2514 1.8
               3771 2.25'
  []
  [specific_heat_metal]
    type = PiecewiseLinear
    x = '-1e7 197.79  298.46  600.31 1401.01 1552.59 1701.44 1e7'
    y = '426.69 426.69 479.77 549.54 676.94  695.14 726.99 726.99'
    scale_factor = 1.0
  []
  # the properties are scaled to the right value and unit (see D. Yushu et al., 2022)
  [thermal_conductivity_metal]
    type = PiecewiseLinear
    x = '-1e7 198.84  298.10  398.75 500.76 601.40 700.64 801.27 901.89 1001.12 1098.98 1200.96 1301.56 1400.78 1501.37 1601.96 1e7'
    y = '247.72 247.72 285.64 323.55 358.44 390.29 417.59 446.41 469.16 491.91 510.11 528.31 540.44 554.09 561.67 569.26 569.26'
    scale_factor = 0.05e-6
  []
  # for monitoring the deposited material geometry
  [x_coord]
    type = ParsedFunction
    expression = 'x'
  []
  [y_coord]
    type = ParsedFunction
    expression = 'y'
  []
  [z_coord]
    type = ParsedFunction
    expression = 'z'
  []
  [temp_ic]
    type = ParsedFunction
    expression = 'if(t<=0, temp_room, temp_melt)'
    symbol_names = 'temp_room temp_melt'
    symbol_values = '${T_room} ${T_melt}'
  []
[]

[Materials]
  [heat_metal]
    type = ADHeatConductionMaterial
    specific_heat_temperature_function = specific_heat_metal
    thermal_conductivity_temperature_function = thermal_conductivity_metal
    temp = temp
    block = '1 2 3'
  []
  [volumetric_heat_metal]
    type = ADFunctionPathGaussianHeatSource
    r = ${r}
    power = ${power}
    efficiency = 0.36
    factor = 1.6
    function_x = heat_source_x
    function_y = heat_source_y
    function_z = heat_source_z
    heat_source_type = 'line'
    threshold_length = 0.1 #mm
    number_time_integration = 10
    block = '1 2 3'
  []
  [density_metal]
    type = ADDensity
    density = 7609e-9 # kg/m^3 -> 1e-9 kg/mm^3
    block = '1 2 3'
  []
[]

[UserObjects]
  [activated_elem_uo_beam]
    type = CoupledVarThresholdElementSubdomainModifier
    execute_on = 'TIMESTEP_BEGIN'
    coupled_var = temp
    block = 1
    subdomain_id = 2
    criterion_type = ABOVE
    threshold = ${T_melt}
    moving_boundary_name = 'moving_boundary'
  []
[]

[Adaptivity]
  marker = marker
  initial_marker = marker
  max_h_level = 2
  [Indicators]
    [indicator]
      type = GradientJumpIndicator
      variable = temp
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

  petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_package -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'preonly lu       superlu_dist NONZERO 1e-10'

  line_search = 'none'

  l_max_its = 100
  nl_max_its = 15
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10

  start_time = 0.0
  end_time = 3771
  dt = ${dt} # ms
  dtmin = 1e-6

  auto_advance = true # cut time-step when subapp fails

  error_on_dtmin = false
[]

[Outputs]
  file_base = 'output/Thermal'
  csv = true
  [exodus]
    type = Exodus
    file_base = 'output/Exodus/Thermal'
    time_step_interval = 1
  []
[]

[Postprocessors]
  [bead_max_temperature]
    type = ElementExtremeValue
    variable = temp
    value_type = max
    block = '2'
    outputs = 'csv'
  []
  [bead_min_temperature]
    type = ElementExtremeValue
    variable = temp
    value_type = min
    block = '2'
    outputs = 'csv'
  []
  [bead_volume]
    type = VolumePostprocessor
    block = '2'
    outputs = 'csv console'
  []
  [bead_x_coord_max]
    type = ElementExtremeValue
    variable = x_coord
    value_type = max
    block = '2'
    outputs = 'csv console'
  []
  [bead_x_coord_min]
    type = ElementExtremeValue
    variable = x_coord
    value_type = min
    block = '2'
    outputs = 'csv'
  []
  [bead_y_coord_max]
    type = ElementExtremeValue
    variable = y_coord
    value_type = max
    block = '2'
    outputs = 'csv console'
  []
  [bead_y_coord_min]
    type = ElementExtremeValue
    variable = y_coord
    value_type = min
    block = '2'
    outputs = 'csv console'
  []
  [bead_z_coord_max]
    type = ElementExtremeValue
    variable = z_coord
    value_type = max
    block = '2'
    outputs = 'csv console'
  []
[]
