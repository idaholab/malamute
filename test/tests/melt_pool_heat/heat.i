[Mesh/gen]
  type = GeneratedMeshGenerator
  dim = 2
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 1
  nx = 40
  ny = 40
  elem_type = QUAD4
[]

[ICs]
  [ls_ic]
    type = FunctionIC
    function = ls_exact
    variable = ls
  []
[]

[Variables]
  [temp]
    initial_condition = 300
  []
  [grad_ls]
    family = LAGRANGE_VEC
  []
[]

[AuxVariables/ls]
[]

[Functions/ls_exact]
   type = LevelSetOlssonPlane
   epsilon = 0.04
   point = '0.5 0.5 0'
   normal = '0 1 0'
[]

[Kernels]
  [grad_ls]
    type = VariableGradientRegularization
    regularized_var = ls
    variable = grad_ls
  []

  [heat_time]
    type = ADHeatConductionTimeDerivative
    specific_heat = specific_heat
    density_name = rho
    variable = temp
  []

  [heat_cond]
    type = ADHeatConduction
    thermal_conductivity = thermal_conductivity
    variable = temp
  []

  [heat_source]
    type = MeltPoolHeatSource
    variable = temp
    laser_power = 100
    effective_beam_radius = 0.2
    absorption_coefficient = 0.27
    heat_transfer_coefficient = 100
    StefanBoltzmann_constant = 5.67e-8
    material_emissivity = 0.59
    ambient_temperature = 300
    laser_location_x = '0.5 + t'
    laser_location_y = '0.5'
    rho_l = 8000
    rho_g = 1.184
    vaporization_latent_heat = 6.1e6
  []
[]

[Materials]
  [thermal]
    type = ADGenericConstantMaterial
    prop_names  = 'rho thermal_conductivity specific_heat melt_pool_mass_rate'
    prop_values = '8000 50 500 0'
  []
  [delta]
    type = LevelSetDeltaFunction
    level_set_gradient = grad_ls
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
  solve_type = NEWTON
  dt = 1e-2
  nl_abs_tol = 1e-7
  num_steps = 2
[]

[Outputs]
  exodus = true
[]
