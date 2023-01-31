#This input file uses the phase-field model originally described by Greenquist et al.,
#Computational Materials Science, 172, 109288 (2020).
#It considers only Y-site vacancies and does not consider the effect of electric potential
#on defect motion.

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 80
  ny = 40
  xmin = 0
  xmax = 80
  ymin = 0
  ymax = 40
  # uniform_refine = 1
[]

[GlobalParams]
  op_num = 4
  var_name_base = gr
  int_width = 4
[]

[Variables]
  [./w]
  [../]
  [./phi]
  [../]
  [./PolycrystalVariables]
  [../]
  [./V]
  [../]
  [./T]
    initial_condition = 1600
  [../]
[]

[AuxVariables]
  [./bnds]
  [../]
  [./F_loc]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./negative_V]
  [../]
  [./E_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./E_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[ICs]
  [./phi_IC]
    type = SpecifiedSmoothCircleIC
    variable = phi
    x_positions = '40 40 1000 2000'
    y_positions = '0  40 1000 1000'
    z_positions = '  0   0   0   0'
    radii = '20 20 0 0'
    invalue = 0
    outvalue = 1
  [../]
  [./gr0_IC]
    type = SmoothCircleIC
    variable = gr0
    x1 = 40
    y1 = 0
    z1 = 0
    radius = 20
    invalue = 1
    outvalue = 0
  [../]
  [./gr1_IC]
    type = SmoothCircleIC
    variable = gr1
    x1 = 40
    y1 = 40
    z1 = 0
    radius = 20
    invalue = 1
    outvalue = 0
  [../]
  [./gr2_IC]
    type = SmoothCircleIC
    variable = gr2
    x1 = 200
    y1 = 320
    z1 = 0
    radius = 160
    invalue = 0
    outvalue = 0
  [../]
  [./gr3_IC]
    type = SmoothCircleIC
    variable = gr3
    x1 = 520
    y1 = 320
    z1 = 0
    radius = 160
    invalue = 0
    outvalue = 0
  [../]
[]

[BCs]
  [./v_top]
    type = DirichletBC
    preset = true
    variable = V
    boundary = top
    value = 400
  [../]
  [./v_bottom]
    type = DirichletBC
    preset = true
    variable = V
    boundary = bottom
    value = 0
  [../]
[]


[Materials]
  # Free energy coefficients for parabolic curves
  [./ks]
    type = ParsedMaterial
    property_name = ks
    coupled_variables = 'T'
    constant_names = 'a b'
    constant_expressions = '-0.0017 140.44'
    expression = 'a*T + b'
  [../]
  [./kv]
    type = ParsedMaterial
    property_name = kv
    material_property_names = 'ks'
    expression = '10*ks'
  [../]
  # Diffusivity and mobilities
  [./chiD]
    type = GrandPotentialTensorMaterial
    f_name = chiD
    solid_mobility = L
    void_mobility = Lv
    chi = chi
    surface_energy = 6.24
    c = phi
    T = T
    D0 = 5.9e9
    GBmob0 = 1.60e12
    Q = 4.14
    Em = 4.25
    bulkindex = 1
    gbindex = 1e6
    surfindex = 1e9
  [../]
  # Everything else
  [./cv_eq]
    type = DerivativeParsedMaterial
    property_name = cv_eq
    coupled_variables = 'gr0 gr1 gr2 gr3 T'
    constant_names = 'Ef c_GB kB'
    constant_expressions = '4.37 0.189 8.617343e-5' #TODO fix GB eq concentration
    derivative_order = 2
    expression = 'c_B:=exp(-Ef/kB/T); bnds:=gr0^2 + gr1^2 + gr2^2 + gr3^2;
                c_B + 4.0 * c_GB * (1.0 - bnds)^2'
  [../]
  [./sintering]
    type = GrandPotentialSinteringMaterial
    chemical_potential = w
    void_op = phi
    Temperature = T
    surface_energy = 6.24
    grainboundary_energy = 5.18
    void_energy_coefficient = kv
    solid_energy_coefficient = ks
    solid_energy_model = PARABOLIC
    equilibrium_vacancy_concentration = cv_eq
  [../]

  # Concentration is only meant for output
  [./c]
    type = ParsedMaterial
    property_name = c
    material_property_names = 'hs rhos hv rhov'
    constant_names = 'Va'
    constant_expressions = '0.0774'
    expression = 'Va*(hs*rhos + hv*rhov)'
    outputs = exodus
  [../]
  [./f_bulk]
    type = ParsedMaterial
    property_name = f_bulk
    coupled_variables = 'phi gr0 gr1 gr2 gr3'
    material_property_names = 'mu gamma'
    expression = 'mu*(phi^4/4-phi^2/2 + gr0^4/4-gr0^2/2 + gr1^4/4-gr1^2/2
                  + gr2^4/4-gr2^2/2 + gr3^4/4-gr3^2/2
                  + gamma*(phi^2*(gr0^2+gr1^2+gr2^2+gr3^2) + gr0^2*(gr1^2+gr2^2+gr3^2)
                  + gr1^2*(gr2^2 + gr3^2) + gr2^2*gr3^2) + 0.25)'
    outputs = exodus
  [../]
  [./f_switch]
    type = ParsedMaterial
    property_name = f_switch
    coupled_variables = 'w'
    material_property_names = 'chi'
    expression = '0.5*w^2*chi'
    outputs = exodus
  [../]
  [./f0]
    type = ParsedMaterial
    property_name = f0
    material_property_names = 'f_bulk f_switch'
    expression = 'f_bulk + f_switch'
  [../]

  [./electrical_conductivity]
    type = DerivativeParsedMaterial
    property_name = electrical_conductivity
    coupled_variables = 'phi T'
    constant_names =       'Q_elec  kB            prefactor_void prefactor_solid'
    constant_expressions = '1.61    8.617343e-5   1.25e-7        1.25e-4'
    derivative_order = 2
    expression = 'phi * prefactor_void * exp(-Q_elec/kB/T) + (1-phi) * prefactor_solid * exp(-Q_elec/kB/T)'
    outputs = exodus
  [../]
  [./thermal_conductivity]
    type = DerivativeParsedMaterial
    property_name = thermal_conductivity
    coupled_variables = 'phi T'
    constant_names =        'prefactor_void  prefactor_solid'
    constant_expressions =  '2.006e-2        2.006e4'
    derivative_order = 2
    expression = '(phi * prefactor_void + (1-phi) * prefactor_solid) / (T - 147.73)'
    outputs = exodus
  [../]
  #as long as thermal conductivity in the void is very low this probably could be a constant
  #but leaving as phi-dependent for now
  [./density]
    type = DerivativeParsedMaterial
    property_name = density
    coupled_variables = 'phi'
    constant_names =        'density_void   density_solid'
    constant_expressions =  '5.01           5.01' #units are g/cm^3
    derivative_order = 2
    expression = 'phi * density_void + (1-phi) * density_solid'
    outputs = exodus
  [../]
  [./specific_heat]
    type = DerivativeParsedMaterial
    property_name = specific_heat
    coupled_variables = 'T'
    constant_names =        'molar_mass   JtoeV     cm3tonm3'
    constant_expressions =  '225.81       1.602e-19 1e-21' #
    expression = 'if(T<1503.7, (3.0183710318246e-19 * T^7 - 2.03644357435399e-15 * T^6
                              + 5.75283959486472e-12 * T^5 - 8.8224198737065e-09 * T^4
                              + 7.96030446457309e-06  * T^3 - 0.00427362972278911 * T^2
                              + 1.30756778141995 * T - 61.6301212149735) / molar_mass / JtoeV * cm3tonm3,
                  (0.0089*T + 119.59) / molar_mass / JtoeV * cm3tonm3)'
    outputs = exodus
  [../]
[]

[Modules]
  [./PhaseField]
    [./GrandPotential]
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
    [../]
  [../]
[]

[Kernels]
  [./barrier_phi]
    type = ACBarrierFunction
    variable = phi
    v = 'gr0 gr1 gr2 gr3'
    gamma = gamma
    mob_name = Lv
  [../]
  [./kappa_phi]
    type = ACKappaFunction
    variable = phi
    mob_name = Lv
    kappa_name = kappa
  [../]
  [./Laplace]
    type = MatDiffusion
    variable = V
    diffusivity = electrical_conductivity
    args = 'phi T'
  [../]
  [./temp_time_derivative]
    type = SpecificHeatConductionTimeDerivative
    variable = T
    specific_heat = specific_heat
    density = density
  [../]
  [./heat_conduction]
    type = HeatConduction
    variable = T
    diffusion_coefficient = thermal_conductivity
  [../]
  [./Joule_heating]
    type = JouleHeatingSource
    variable = T
    elec = V
    electrical_conductivity = electrical_conductivity
    coupled_variables = 'phi'
  [../]
[]


[AuxKernels]
  [./bnds_aux]
    type = BndsCalcAux
    variable = bnds
    execute_on = 'initial timestep_end'
  [../]
  [./F_aux]
    type = TotalFreeEnergy
    variable = F_loc
    f_name = f0
    interfacial_vars = 'phi gr0 gr1 gr2 gr3'
    kappa_names = 'kappa kappa kappa kappa kappa'
  [../]
  [./negative_V]
    type = ParsedAux
    variable = negative_V
    coupled_variables = V
    expression = '-V'
  [../]
  [./E_x]
    type = VariableGradientComponent
    variable = E_x
    gradient_variable = negative_V
    component = x
  [../]
  [./E_y]
    type = VariableGradientComponent
    variable = E_y
    gradient_variable = negative_V
    component = y
  [../]
[]

[Postprocessors]
  [./memory]
    type = MemoryUsage
    outputs = csv
  [../]
  [./n_DOFs]
    type = NumDOFs
    outputs = csv
  [../]
  [./c_total]
    type = ElementIntegralMaterialProperty
    mat_prop = c
    outputs = csv
  [../]
  [./total_energy]
    type = ElementIntegralVariablePostprocessor
    variable = F_loc
    outputs = csv
  [../]
  [./void_tracker]
    type = FeatureFloodCount
    execute_on = 'initial timestep_end'
    variable = phi
    threshold = 0.5
    compute_var_to_feature_map = true
  [../]
[]

[VectorPostprocessors]
  [./neck]
    type = LineValueSampler
    start_point = '0 20 0'
    end_point = '40 20 0'
    num_points = 41
    variable = 'gr0 gr1 gr2 gr3 phi'
    sort_by = x
  [../]
[]

[UserObjects]
  [./terminator]
    type = Terminator
    expression = 'void_tracker = 1'
    execute_on = TIMESTEP_END
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart -sub_ksp_type'
  petsc_options_value = ' asm      lu           1               31                 preonly'
  nl_max_its = 40
  l_max_its = 30
  l_tol = 1e-4
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-7
  start_time = 0
  end_time = 500
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
    optimal_iterations = 8
    iteration_window = 2
  [../]
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
  checkpoint = true
[]
