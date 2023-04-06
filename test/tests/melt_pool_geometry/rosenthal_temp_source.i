[Mesh]
  type = GeneratedMesh
  dim = 2
  xmax = 2.0
  ymin = -1
  ymax = 1
  nx = 2
  ny = 2
[]

[Variables]
  [temp]
    initial_condition = 393
  []
[]

[AuxVariables]
  [temp_src]
    order = FIRST
    family = MONOMIAL
  []
[]

[AuxKernels]
  [temp_src]
    type = ADMaterialRealAux
    variable = temp_src
    property = temp_source
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
[]

[Materials]
  [heat]
    type = ADHeatConductionMaterial
    specific_heat = 500
    thermal_conductivity = 20
  []
  [density]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '8000'
  []
  [meltpool]
    type = ADRosenthalTemperatureSource
    power = 1000
    velocity = 2.0
    absorptivity = 1.0
    melting_temperature = 1660
    ambient_temperature = 393
  []
[]

[Postprocessors]
  [meltpool_depth]
    type = ADElementAverageMaterialProperty
    mat_prop = meltpool_depth
  []
  [meltpool_width]
    type = ADElementAverageMaterialProperty
    mat_prop = meltpool_width
  []
[]

[Preconditioning]
  [full]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-6

  petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'preonly lu       superlu_dist'

  l_max_its = 100

  # end_time = 20
  num_steps = 2
  dt = 0.1
  dtmin = 1e-4
[]

[Outputs]
  exodus = true
  csv = true
[]
