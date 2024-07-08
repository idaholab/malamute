initial_temperature = 1350
initial_voltage = 3.95e7 #from the engineering scale at the specific element
initial_current_density = -5.6e-10 # -5.8e-10 #roughly for 1350K #nV/nm * \sigma
# lower_flux=1.0e-9 #roughly calculated from the original marmot example problem

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 80
    ny = 40
    xmin = 0
    xmax = 80
    ymin = 0
    ymax = 40
  []
  [new_nodeset]
    input = gen
    type = ExtraNodesetGenerator
    coord = '40 20'
    new_boundary = 1000
  []
[]

[Problem]
  type = ReferenceResidualProblem
  reference_vector = 'ref'
  extra_tag_vectors = 'ref'
  group_variables = 'Tx_AEH Ty_AEH; Vx_AEH Vy_AEH'
[]

[GlobalParams]
  op_num = 4
  var_name_base = gr
  int_width = 4
[]

[Variables]
  [w]
  []
  [phi]
  []
  [PolycrystalVariables]
  []

  [Tx_AEH]
    #Temperature used for the x-component of the AEH solve
    initial_condition = ${initial_temperature} # should match the initial auxvariable value
    # scaling = 1.0e-4 #Scales residual to improve convergence
  []
  [Ty_AEH]
    #Temperature used for the y-component of the AEH solve
    initial_condition = ${initial_temperature}
    # scaling = 1.0e-4  #Scales residual to improve convergence
  []

  [V]
    ##defined in nVolts
  []
  [Vx_AEH]
    # Voltage potential used for the x-component of the AEH solve
    initial_condition = ${initial_voltage} # should match the initial auxvariable value
  []
  [Vy_AEH]
    #Voltage potential used for the y-component of the AEH solve
    initial_condition = ${initial_voltage}
  []
[]

[AuxVariables]
  [bnds]
  []
  [F_loc]
    order = CONSTANT
    family = MONOMIAL
  []
  [negative_V]
  []
  [E_x]
    order = CONSTANT
    family = MONOMIAL
  []
  [E_y]
    order = CONSTANT
    family = MONOMIAL
  []
  [temperature_in]
    initial_condition = ${initial_temperature} #Try with the higher temperature first, then go to lower temperatures
  []
[]

[ICs]
  [phi_IC]
    type = SpecifiedSmoothCircleIC
    variable = phi
    x_positions = '20 20  60 60'
    y_positions = ' 0 40 -10 30'
    z_positions = ' 0  0   0  0'
    radii = '20 20 20 20'
    invalue = 0
    outvalue = 1
  []
  [gr0_IC]
    type = SmoothCircleIC
    variable = gr0
    x1 = 20
    y1 = 0
    z1 = 0
    radius = 20
    invalue = 1
    outvalue = 0
  []
  [gr1_IC]
    type = SmoothCircleIC
    variable = gr1
    x1 = 20
    y1 = 40
    z1 = 0
    radius = 20
    invalue = 1
    outvalue = 0
  []
  [gr2_IC]
    type = SmoothCircleIC
    variable = gr2
    x1 = 60
    y1 = -10
    z1 = 0
    radius = 20
    invalue = 1
    outvalue = 0
  []
  [gr3_IC]
    type = SmoothCircleIC
    variable = gr3
    x1 = 60
    y1 = 30
    z1 = 0
    radius = 20
    invalue = 1
    outvalue = 0
  []
[]

[BCs]
  [from_macroapp_potential]
    type = PostprocessorDirichletBC
    postprocessor = potential_in
    variable = V
    boundary = top
  []
  [vflux_bottom]
    type = PostprocessorNeumannBC
    postprocessor = current_density_in
    variable = V
    boundary = bottom
  []

  [Periodic]
    [left_right_tx]
      primary = left
      secondary = right
      translation = '80 0 0'
      variable = Tx_AEH
    []
    [bottom_top_ty]
      primary = bottom
      secondary = top
      translation = '0 40 0'
      variable = Ty_AEH
    []
    [left_right_vx]
      primary = left
      secondary = right
      translation = '80 0 0'
      variable = Vx_AEH
    []
    [bottom_top_vy]
      primary = bottom
      secondary = top
      translation = '0 40 0'
      variable = Vy_AEH
    []
  []
  [fix_AEH_Tx]
    #Fix Tx_AEH at a single point
    type = PostprocessorDirichletBC
    variable = Tx_AEH
    postprocessor = center_temperature
    boundary = 1000
  []
  [fix_AEH_Ty]
    #Fix Ty_AEH at a single point
    type = PostprocessorDirichletBC
    variable = Ty_AEH
    postprocessor = center_temperature
    boundary = 1000
  []
  [fix_AEH_Vx]
    #Fix Tx_AEH at a single point
    type = PostprocessorDirichletBC
    variable = Vx_AEH
    postprocessor = potential_in
    boundary = 1000
  []
  [fix_AEH_Vy]
    #Fix Ty_AEH at a single point
    type = PostprocessorDirichletBC
    variable = Vy_AEH
    postprocessor = potential_in
    boundary = 1000
  []
[]

[Materials]
  # Free energy coefficients for parabolic curves
  [ks]
    type = ParsedMaterial
    property_name = ks
    coupled_variables = 'temperature_in'
    constant_names = 'a b'
    constant_expressions = '-0.0017 140.44'
    expression = 'a*temperature_in + b'
  []
  [kv]
    type = ParsedMaterial
    property_name = kv
    material_property_names = 'ks'
    expression = '10*ks'
  []
  # Diffusivity and mobilities
  [chiD]
    type = GrandPotentialTensorMaterial
    f_name = chiD
    solid_mobility = L
    void_mobility = Lv
    chi = chi
    surface_energy = 6.24
    c = phi
    T = temperature_in
    D0 = 5.9e9
    GBmob0 = 1.60e12
    Q = 4.14
    Em = 4.25
    bulkindex = 1
    gbindex = 1e6
    surfindex = 1e9
  []
  # Everything else
  [cv_eq]
    type = DerivativeParsedMaterial
    property_name = cv_eq
    coupled_variables = 'gr0 gr1 gr2 gr3 temperature_in'
    constant_names = 'Ef c_GB kB'
    constant_expressions = '4.37 0.189 8.617343e-5' #TODO fix GB eq concentration
    derivative_order = 2
    expression = 'c_B:=exp(-Ef/kB/temperature_in); bnds:=gr0^2 + gr1^2 + gr2^2 + gr3^2;
                c_B + 4.0 * c_GB * (1.0 - bnds)^2'
  []
  [sintering]
    type = GrandPotentialSinteringMaterial
    chemical_potential = w
    void_op = phi
    Temperature = temperature_in
    surface_energy = 6.24
    grainboundary_energy = 5.18
    void_energy_coefficient = kv
    solid_energy_coefficient = ks
    solid_energy_model = PARABOLIC
    equilibrium_vacancy_concentration = cv_eq
  []

  # Concentration is only meant for output
  [c]
    type = ParsedMaterial
    property_name = c
    material_property_names = 'hs rhos hv rhov'
    constant_names = 'Va'
    constant_expressions = '0.0774'
    expression = 'Va*(hs*rhos + hv*rhov)'
    outputs = exodus
  []
  [f_bulk]
    type = ParsedMaterial
    property_name = f_bulk
    coupled_variables = 'phi gr0 gr1 gr2 gr3'
    material_property_names = 'mu gamma'
    expression = 'mu*(phi^4/4-phi^2/2 + gr0^4/4-gr0^2/2 + gr1^4/4-gr1^2/2
                  + gr2^4/4-gr2^2/2 + gr3^4/4-gr3^2/2
                  + gamma*(phi^2*(gr0^2+gr1^2+gr2^2+gr3^2) + gr0^2*(gr1^2+gr2^2+gr3^2)
                  + gr1^2*(gr2^2 + gr3^2) + gr2^2*gr3^2) + 0.25)'
    outputs = exodus
  []
  [f_switch]
    type = ParsedMaterial
    property_name = f_switch
    coupled_variables = 'w'
    material_property_names = 'chi'
    expression = '0.5*w^2*chi'
    outputs = exodus
  []
  [f0]
    type = ParsedMaterial
    property_name = f0
    material_property_names = 'f_bulk f_switch'
    expression = 'f_bulk + f_switch'
  []

  [electrical_conductivity]
    type = ADDerivativeParsedMaterial
    property_name = electrical_conductivity
    coupled_variables = 'phi temperature_in'
    constant_names =       'Q_elec  kB            prefactor_void prefactor_solid'
    constant_expressions = '1.61    8.617343e-5   1.25e-7        1.25e-4'
    derivative_order = 2
    expression = 'phi * prefactor_void * exp(-Q_elec/kB/temperature_in) + (1-phi) * prefactor_solid * exp(-Q_elec/kB/temperature_in)' # in eV/(nV^2 s nm) per chat with Larry
    outputs = exodus
  []
  [convert_ad_electrical_conductivity]
    type = MaterialADConverter
    ad_props_in = 'electrical_conductivity'
    reg_props_out = 'reg_electrical_conductivity'
  []

  [thermal_conductivity]
    type = ParsedMaterial
    property_name = thermal_conductivity
    coupled_variables = 'phi temperature_in'
    constant_names = 'prefactor_void  prefactor_solid'
    constant_expressions = '0.025        3214.06' #in W/(m-K) #solid value from Larry's curve fitting, data from Klein and Croft, JAP, v. 38, p. 1603 and UC report "For Computer Heat Conduction Calculations - A compilation of thermal properties data" by A.L. Edwards, UCRL-50589 (1969)
    expression = '(phi * prefactor_void + (1-phi) * prefactor_solid) / (temperature_in - 147.73)'
    outputs = exodus
  []
  #as long as thermal conductivity in the void is very low this probably could be a constant
  #but leaving as phi-dependent for now
  [density]
    type = DerivativeParsedMaterial
    property_name = density
    coupled_variables = 'phi'
    constant_names = 'density_void   density_solid'
    constant_expressions = '1.25           5.01e3' #units are kg/m^3
    derivative_order = 2
    expression = 'phi * density_void + (1-phi) * density_solid'
    outputs = exodus
  []
  [specific_heat]
    type = DerivativeParsedMaterial
    property_name = specific_heat
    coupled_variables = 'phi'
    material_property_names = 'specific_heat_yttria'
    constant_names = 'specific_heat_void'
    constant_expressions = '1.005e3' #units are J/(K-kg)
    expression = 'phi * specific_heat_void + (1-phi) * specific_heat_yttria'
    outputs = exodus
  []
  [specific_heat_yttria]
    type = DerivativeParsedMaterial
    property_name = specific_heat_yttria
    coupled_variables = 'temperature_in'
    constant_names =       'molar_mass   gtokg'
    constant_expressions = '225.81       1.0e3'
    expression = 'if(temperature_in<1503.7, (3.0183710318246e-19 * temperature_in^7 - 2.03644357435399e-15 * temperature_in^6
                              + 5.75283959486472e-12 * temperature_in^5 - 8.8224198737065e-09 * temperature_in^4
                              + 7.96030446457309e-06  * temperature_in^3 - 0.00427362972278911 * temperature_in^2
                              + 1.30756778141995 * temperature_in - 61.6301212149735) / molar_mass * gtokg,
                  (0.0089*temperature_in + 119.59) / molar_mass * gtokg)' #in J/(K-kg)
    outputs = exodus
  []
[]

[Modules]
  [PhaseField]
    [GrandPotential]
      switching_function_names = 'hv hs'
      anisotropic = 'true'

      chemical_potentials = 'w'
      mobilities = 'chiD'
      susceptibilities = 'chi'
      free_energies_w = 'rhov rhos'

      gamma_gr = gamma
      mobility_name_gr = L
      kappa_gr = kappa
      free_energies_gr = 'omegav omegas'

      additional_ops = 'phi'
      gamma_grxop = gamma
      mobility_name_op = Lv
      kappa_op = kappa
      free_energies_op = 'omegav omegas'
    []
  []
[]

[Kernels]
  [barrier_phi]
    type = ACBarrierFunction
    variable = phi
    v = 'gr0 gr1 gr2 gr3'
    gamma = gamma
    mob_name = Lv
    extra_vector_tags = 'ref'
  []
  [kappa_phi]
    type = ACKappaFunction
    variable = phi
    mob_name = Lv
    kappa_name = kappa
    extra_vector_tags = 'ref'
  []
  [electric_yttria]
    type = ADMatDiffusion
    variable = V
    diffusivity = electrical_conductivity
    extra_vector_tags = 'ref'
  []
  # [./Laplace]
  #   type = MatDiffusion
  #   variable = V
  #   diffusivity = electrical_conductivity
  #   args = 'phi temperature_in'
  # [../]
  # [./temp_time_derivative]
  #   type = SpecificHeatConductionTimeDerivative
  #   variable = temperature_in
  #   specific_heat = specific_heat
  #   density = density
  # [../]
  # [./heat_conduction]
  #   type = HeatConduction
  #   variable = temperature_in
  #   diffusion_coefficient = thermal_conductivity
  # [../]
  # [./Joule_heating]
  #   type = JouleHeatingSource
  #   variable = temperature_in
  #   elec = V
  #   electrical_conductivity = electrical_conductivity
  #   args = 'phi'
  # [../]

  [heat_x]
    #All other kernels are for AEH approach to calculate thermal cond.
    type = HeatConduction
    variable = Tx_AEH
    diffusion_coefficient = thermal_conductivity
    extra_vector_tags = 'ref'
  []
  [heat_rhs_x]
    type = HomogenizedHeatConduction
    variable = Tx_AEH
    component = 0
    diffusion_coefficient = thermal_conductivity
    extra_vector_tags = 'ref'
  []
  [heat_y]
    type = HeatConduction
    variable = Ty_AEH
    diffusion_coefficient = thermal_conductivity
    extra_vector_tags = 'ref'
  []
  [heat_rhs_y]
    type = HomogenizedHeatConduction
    variable = Ty_AEH
    component = 1
    diffusion_coefficient = thermal_conductivity
    extra_vector_tags = 'ref'
  []

  [voltage_x]
    #The following four kernels are for AEH approach to calculate electrical cond.
    type = HeatConduction
    variable = Vx_AEH
    diffusion_coefficient = reg_electrical_conductivity
    extra_vector_tags = 'ref'
  []
  [voltage_rhs_x]
    type = HomogenizedHeatConduction
    variable = Vx_AEH
    component = 0
    diffusion_coefficient = reg_electrical_conductivity
    extra_vector_tags = 'ref'
  []
  [voltage_y]
    type = HeatConduction
    variable = Vy_AEH
    diffusion_coefficient = reg_electrical_conductivity
    extra_vector_tags = 'ref'
  []
  [voltage_rhs_y]
    type = HomogenizedHeatConduction
    variable = Vy_AEH
    component = 1
    diffusion_coefficient = reg_electrical_conductivity
    extra_vector_tags = 'ref'
  []
[]

[AuxKernels]
  [bnds_aux]
    type = BndsCalcAux
    variable = bnds
    execute_on = 'initial timestep_end'
  []
  [F_aux]
    type = TotalFreeEnergy
    variable = F_loc
    f_name = f0
    interfacial_vars = 'phi gr0 gr1 gr2 gr3'
    kappa_names = 'kappa kappa kappa kappa kappa'
  []
  [negative_V]
    type = ParsedAux
    variable = negative_V
    coupled_variables = V
    expression = '-V'
  []
  [E_x]
    type = VariableGradientComponent
    variable = E_x
    gradient_variable = negative_V
    component = x
  []
  [E_y]
    type = VariableGradientComponent
    variable = E_y
    gradient_variable = negative_V
    component = y
  []
[]

[Postprocessors]
  [temperature_auxvar]
    type = AverageNodalVariableValue
    variable = temperature_in
  []
  [center_temperature]
    type = Receiver
    default = ${initial_temperature}
  []
  [potential_in]
    type = Receiver
    default = ${initial_voltage}
  []
  [current_density_in]
    type = Receiver
    default = ${initial_current_density}
  []

  [k_eff]
    type = ElementAverageMaterialProperty
    mat_prop = thermal_conductivity
  []
  [cp_eff]
    type = ElementAverageMaterialProperty
    mat_prop = specific_heat
  []
  [density_eff]
    type = ElementAverageMaterialProperty
    mat_prop = density
  []
  [k_x_AEH]
    #Effective thermal conductivity in x-direction from AEH
    type = HomogenizedThermalConductivity
    chi = 'Tx_AEH Ty_AEH'
    row = 0
    col = 0
    execute_on = TIMESTEP_END
    # scale_factor = 1e6 #Scale due to length scale of problem
  []
  [k_y_AEH]
    #Effective thermal conductivity in x-direction from AEH
    type = HomogenizedThermalConductivity
    chi = 'Tx_AEH Ty_AEH'
    row = 1
    col = 1
    execute_on = TIMESTEP_END
    # scale_factor = 1e6 #Scale due to length scale of problem
  []
  [k_AEH_average]
    type = LinearCombinationPostprocessor
    pp_coefs = '0.5 0.5'
    pp_names = 'k_x_AEH k_y_AEH'
  []

  [sigma_eff]
    type = ADElementAverageMaterialProperty
    mat_prop = electrical_conductivity
  []
  [sigma_x_AEH]
    #Effective electrical conductivity in x-direction from AEH
    type = HomogenizedThermalConductivity
    chi = 'Vx_AEH Vy_AEH'
    row = 0
    col = 0
    diffusion_coefficient = reg_electrical_conductivity
    execute_on = TIMESTEP_END
    # scale_factor = 1e6 #Scale due to length scale of problem
  []
  [sigma_y_AEH]
    #Effective electrical conductivity in x-direction from AEH
    type = HomogenizedThermalConductivity
    chi = 'Vx_AEH Vy_AEH'
    row = 1
    col = 1
    diffusion_coefficient = reg_electrical_conductivity
    execute_on = TIMESTEP_END
    # scale_factor = 1e6 #Scale due to length scale of problem
  []
  [sigma_AEH_average]
    type = LinearCombinationPostprocessor
    pp_coefs = '0.5 0.5'
    pp_names = 'sigma_x_AEH sigma_y_AEH'
  []

  [c_total]
    type = ElementIntegralMaterialProperty
    mat_prop = c
    outputs = csv
  []
  [total_energy]
    type = ElementIntegralVariablePostprocessor
    variable = F_loc
    outputs = csv
  []
  [void_tracker]
    type = FeatureFloodCount
    execute_on = 'initial timestep_end'
    variable = phi
    threshold = 0.5
    compute_var_to_feature_map = true
  []
  [rough_phi]
    type = ElementAverageValue
    variable = phi
  []
[]

# [VectorPostprocessors]
#   [./neck]
#     type = LineValueSampler
#     start_point = '0 20 0'
#     end_point = '40 20 0'
#     num_points = 41
#     variable = 'gr0 gr1 gr2 gr3 phi'
#     sort_by = x
#   [../]
# []

[UserObjects]
  [terminator]
    type = Terminator
    expression = 'void_tracker = 1'
    execute_on = TIMESTEP_END
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = PJFNK
  #options from Dewen to factorize the entire jacobian
  # petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  # petsc_options_value = 'lu NONZERO   1e-15'

  #options to inspect for singular matrix
  # petsc_options = '-snes_converged_reason -pc_svd_monitor'
  # petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  # petsc_options_value = 'svd NONZERO   1e-15'

  # options from Larry
  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart -sub_ksp_type'
  petsc_options_value = ' asm      lu           1               31                 preonly'

  #options from Alex
  # petsc_options = '-snes_converged_reason -ksp_converged_reason -options_left -ksp_monitor_singular_value'
  # petsc_options_iname = '-ksp_max_it -ksp_gmres_restart -pc_type -snes_max_funcs -sub_pc_factor_levels'
  # petsc_options_value = ' 100         100                asm      1000000         1'

  automatic_scaling = true
  scaling_group_variables = 'Tx_AEH Ty_AEH; Vx_AEH Vy_AEH'
  compute_scaling_once = false
  nl_max_its = 100 #40
  l_max_its = 100 #20 #25
  l_tol = 1e-4
  nl_rel_tol = 1e-6
  nl_abs_tol = 3e-7 #1e-7
  start_time = 0
  # end_time = 500
  dtmin = 1.0e-4
  timestep_tolerance = 1e-8
  # num_steps = 10
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 10.0
    optimal_iterations = 8
    iteration_window = 2
  []
  # [./Adaptivity]
  #   refine_fraction = 0.8
  #   coarsen_fraction = 0.2
  #   max_h_level = 2
  #   initial_adaptivity = 1
  # [../]
[]

[Outputs]
  perf_graph = true
  csv = true
  exodus = true
[]
