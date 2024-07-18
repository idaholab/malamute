# This model includes only heat conduction on a two element block and is intended
# verify the curve fits from Cincotti et al (2007) AIChE Journal, Vol 53 No 3,
# page 710 Figure 7b.
#
# Experimental data points which nearly lie on the curve fit are compared to the
# simulation outputs at similar temperatures, below, to verify both the curve
# fits and the material model tested here:
#
# Electrical Resistivity (Ohm/m):
#        Experimental Data Point                Simulation Result
#  Temperature(K)  Electrical Resistivity  Temperature(K)  Electrical Resistivity
#      713.0            1.05e-5                   713.0          1.048e-05

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
  [graphite_potential]
  []
[]

[AuxVariables]
  [temperature]
    initial_condition = 713.0
  []
[]

[Kernels]
  [electric_graphite]
    type = ADMatDiffusion
    variable = graphite_potential
    diffusivity = electrical_conductivity
  []
[]

[BCs]
  [elec_top]
    type = ADDirichletBC
    variable = graphite_potential
    boundary = top
    value = 10
  []
  [elec_bottom]
    type = ADDirichletBC
    variable = graphite_potential
    boundary = bottom
    value = 0
  []
[]

[Materials]
  [graphite_electrical]
    type = ADGraphiteElectricalConductivity
    temperature = temperature
  []
  [graphite_electrical_resistivity]
    type = ADParsedMaterial
    property_name = electrical_resistivity
    material_property_names = electrical_conductivity
    expression = '1 / electrical_conductivity'
  []
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
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
    type = ADElementExtremeMaterialProperty
    mat_prop = electrical_resistivity
    value_type = max
  []
[]

[Outputs]
  csv = true
  perf_graph = true
  file_base = graphite_electrical_material_properties_out
[]
