[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 3
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 0.5
    zmin = 0
    zmax = 0.1
    nx = 10
    ny = 5
    nz = 1
  []
[]

[Variables]
  [temp]
  []
[]

[ICs]
  [temp_substrate]
    type = ConstantIC
    variable = temp
    value = 300
  []
[]

[Kernels]
  [time]
    type = ADHeatConductionTimeDerivative
    variable = temp
  []
  [heat_conduct]
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

[BCs]
  [temp_bottom_fix]
    type = ADDirichletBC
    variable = temp
    boundary = back
    value = 300
  []
[]

[Materials]
  [volumetric_heat]
    type = VelocityGaussianHeatSource
    r = '0.2 0.3 0.1'
    power = 0.3
    efficiency = 0.3
    factor = 2
    y0 = 0.25
    z0 = 0.1
    function_vx = 0.05
    heat_source_type = 'mixed'
    threshold_length = 0.1
  []
  [density]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = 7609e-9
  []
  [heat]
    type = ADHeatConductionMaterial
    specific_heat_temperature_function = 500
    thermal_conductivity_temperature_function = 25e-6
    temp = temp
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

  automatic_scaling = true

  solve_type = 'PJFNK'

  petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'preonly lu       superlu_dist'

  line_search = 'none'

  l_max_its = 20
  nl_max_its = 10
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  start_time = 0.0
  end_time = 20
  dt = 1
  dtmin = 1e-4
[]

[Outputs]
  csv = true
[]

[Postprocessors]
  [avg_temp]
    type = ElementAverageValue
    variable = temp
  []
  [max_temp]
    type = ElementExtremeValue
    variable = temp
    value_type = max
  []
  [min_temp]
    type = ElementExtremeValue
    variable = temp
    value_type = min
  []
[]
