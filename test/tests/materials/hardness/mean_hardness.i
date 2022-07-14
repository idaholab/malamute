# This test demonstrates the capability of the GraphiteStainlessMeanHardness
# ADMaterial object. Using the values below for AT 101 graphite and AISI 304
# stainless steel taken from Cincotti et al (DOI: 10.1002/aic.11102), the object
# calculates the harmonic mean of the hardness value. This is to be used in
# calculating thermal and electrical contact conductances.
#
#                           Hardness (Pa)
#      Stainless Steel        1.92e9
#             Graphite        3.5e9
#        Harmonic Mean        ~2.4797e9

[Mesh]
  [generated]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 2
    ny = 2
  []
[]

[Problem]
  type = FEProblem
  solve = false
[]

[Materials]
  [mean_hardness]
    type = GraphiteStainlessMeanHardness
    output_properties = 'graphite_stainless_mean_hardness'
    outputs = exodus
  []
[]

[Executioner]
  type = Steady
[]

[Outputs]
  exodus = true
[]
