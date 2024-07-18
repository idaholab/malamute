# This model includes only electrical conducation on a two element block and is
# intended verify the curve fits from Cincotti et al (2007) AIChE Journal,
#  Vol 53 No 3, page 711 Figure 8b.
#
# Experimental data points which nearly lie on the curve fit are compared to the
# simulation outputs at similar temperatures, below, to verify both the curve
# fits and the material model tested here:
#
# Electrical Resistivity (Ohm/m):
#        Experimental Data Point                Simulation Result
#  Temperature(K)  Electrical Resistivity  Temperature(K)  Electrical Resistivity
#      572.9            9.30e-7                   573.0          9.310e-07

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 1
  ny = 2
  xmax = 0.01 #1cm
  ymax = 0.02 #2cm
  coord_type = RZ
[]

[Variables]
  [stainless_steel_potential]
  []
[]

[AuxVariables]
  [temperature]
    initial_condition = 573.0
  []
[]

[Kernels]
  [electric_stainless_steel]
    type = ADMatDiffusion
    variable = stainless_steel_potential
    diffusivity = ad_electrical_conductivity
  []
[]

[BCs]
  [elec_top]
    type = DirichletBC
    variable = stainless_steel_potential
    boundary = top
    value = 10
  []
  [elec_bottom]
    type = DirichletBC
    variable = stainless_steel_potential
    boundary = bottom
    value = 0
  []
[]

[Materials]
  [stainless_steel_electrical]
    type = StainlessSteelElectricalConductivity
    temperature = temperature
  []
  [converter]
    type = MaterialADConverter
    reg_props_in = electrical_conductivity
    ad_props_out = ad_electrical_conductivity
  []
  [stainless_steel_electrical_resistivity]
    type = ParsedMaterial
    property_name = electrical_resistivity
    material_property_names = electrical_conductivity
    expression = '1 / electrical_conductivity'
  []
[]

[Executioner]
  type = Steady
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm          ilu         1'
  automatic_scaling = true
[]

[Postprocessors]
  [max_temperature]
    type = NodalExtremeValue
    variable = temperature
    value_type = max
  []
  [max_electrical_resistivity]
    type = ElementExtremeMaterialProperty
    mat_prop = electrical_resistivity
    value_type = max
  []
[]

[Outputs]
  csv = true
  perf_graph = true
[]
