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
  [velocity]
    type = VectorConstantIC
    x_value = 1e-15
    y_value = 1e-15
    variable = velocity
  []
[]

[Variables]
  [temp]
    initial_condition = 300
  []
  [grad_ls]
    family = LAGRANGE_VEC
  []
  [velocity]
    family = LAGRANGE_VEC
  []
  [p]
  []
  [curvature]
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
  [curvature]
    type = LevelSetCurvatureRegularization
    level_set_regularized_gradient = grad_ls
    variable = curvature
    epsilon = 0.04
  []

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

  [heat_conv]
    type = INSADTemperatureAdvection
    variable = temp
    velocity = velocity
    cp_name = specific_heat
    rho_name = rho
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
  []

  [mass]
    type = INSADMass
    variable = p
    []
  [mass_pspg]
    type = INSADMassPSPG
    variable = p
  []

  [momentum_time]
    type = INSADMomentumTimeDerivative
    variable = velocity
  []

  [momentum_convection]
    type = INSADMomentumAdvection
    variable = velocity
  []

  [momentum_viscous]
    type = INSADMomentumViscous
    variable = velocity
  []

  [momentum_pressure]
    type = INSADMomentumPressure
    variable = velocity
    p = p
    integrate_p_by_parts = true
  []

  [momentum_supg]
    type = INSADMomentumSUPG
    variable = velocity
    velocity = velocity
  []

  [melt_pool_momentum_source]
    type = INSMeltPoolMomentumSource
    variable = velocity
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
  [delta]
    type = LevelSetDeltaFunction
    level_set_gradient = grad_ls
  []
  [heaviside]
    type = LevelSetHeavisideFunction
    level_set = ls
  []
  [ins_melt_pool_mat]
    type = INSMeltPoolMaterial
    level_set_gradient = grad_ls
    velocity = velocity
    pressure = p
    alpha = .1
    temperature = temp
    curvature = curvature
    surface_tension = 1.169
    thermal_capillary = -4.3e-4
  []
  [fluid]
    type = LevelSetFluidMaterial
    rho_g = 1.184
    rho_s = 8000
    rho_l = 8000
    mu_g = 1.81e-5
    mu_l = 0.1
    permeability_constant = 1e-8
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
  line_search = 'none'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

[Outputs]
  exodus = true
[]
