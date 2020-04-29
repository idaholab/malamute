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

[AuxVariables]
  [ls]
  []
[]

[Functions/ls_exact]
   type = LevelSetOlssonPlane
   epsilon = 0.04
   point = '0.5 0.5 0'
   normal = '0 1 0'
[]

[Kernels]
  [./grad_ls]
    type = VariableGradientRegularization
    regularized_var = ls
    variable = grad_ls
  [../]

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
    laser_power = 250
    effective_beam_radius = 0.1
    absorption_coefficient = 0.27
    heat_transfer_coefficient = 100
    StefanBoltzmann_constant = 5.67e-8
    material_emissivity = 0.59
    ambient_temperature = 300
    laser_location_x = '0.5'
    laser_location_y = '0.5'
  []
[]

[Materials]
  [thermal]
    type = LevelSetThermalMaterial
    temperature = temp
    c_g = 300
    c_s = 500
    c_l = 500
    k_g = 0.017
    k_s = 31.8724
    k_l = 209.3
    solidus_temperature = 1648
    latent_heat = 2.5e5
  []
  [mushy]
    type = MushyZoneMaterial
    temperature = temp
    liquidus_temperature = 1673
    solidus_temperature = 1648
    rho_s = 8000
    rho_l = 8000
  []
  [rho]
    type = ADGenericConstantMaterial
    prop_names  = 'rho'
    prop_values = '8000'
  []
  [heaviside]
    type = LevelSetHeavisideFunction
    level_set = ls
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
  dt = 1
  nl_abs_tol = 1e-7
  num_steps = 2
[]

[Outputs]
  exodus = true
[]
