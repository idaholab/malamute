## Parameters for the standard DCS-5 geometry and mesh, units in meters

ram_spacer_radius = 0.031
ram_spacer_height = 0.020
ram_spacer_overhang_radius = 0.01
ram_spacer_overhang_height = 0.002

cc_spacer_radius = 0.020
cc_spacer_height = 0.00635

sinter_spacer_radius = 0.020
sinter_spacer_height = 0.027
sinter_spacer_overhang_radius = 0.0135 ## is less than the 13.55 that actually exists
sinter_spacer_overhang_height = 0.002

punch_radius = 0.006
punch_height = 0.020

powder_radius = 0.006
powder_height = 0.00984

die_wall_height = 0.030
die_wall_inner_radius = 0.006125
die_wall_thickness = 0.013875



#######################################################################################
### Calculated values from user-provided results
ram_spacer_surface_area = ${fparse pi * ram_spacer_radius * ram_spacer_radius}
# ram_spacer_overhang_offset = ${fparse ram_spacer_radius - ram_spacer_overhang_radius}
ram_cc_spacers_height = ${fparse ram_spacer_height + cc_spacer_height}
ram_cc_sinter_spacers_height = ${fparse ram_cc_spacers_height + sinter_spacer_height}
ram_cc_sinter_punch_height = ${fparse ram_cc_sinter_spacers_height + punch_height}
die_wall_outer_radius = ${fparse die_wall_inner_radius + die_wall_thickness}
stack_with_powder = ${fparse ram_cc_sinter_punch_height + powder_height}



[Mesh]
  [bottom_ram_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 31
    ny = 20
    xmax = ${ram_spacer_radius}
    ymax = ${ram_spacer_height}
    boundary_name_prefix = bottom_ram_spacer
    elem_type = QUAD8
  []
  [bottom_ram_overhang]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 2
    xmin = ${fparse ram_spacer_radius - ram_spacer_overhang_radius}
    xmax = ${ram_spacer_radius}
    ymin = ${ram_spacer_height}
    ymax = ${fparse ram_spacer_height + ram_spacer_overhang_height}
    boundary_name_prefix = bottom_ram_spacer_overhang
    elem_type = QUAD8
  []
  [stitch_bottom_ram_spacer]
    type = StitchedMeshGenerator
    inputs = 'bottom_ram_spacer bottom_ram_overhang'
    stitch_boundaries_pairs = 'bottom_ram_spacer_top bottom_ram_spacer_overhang_bottom'
  []
  [bottom_ram_spacer_block]
    type = SubdomainIDGenerator
    input = 'stitch_bottom_ram_spacer'
    subdomain_id = '1'
  []
  [bottom_cc_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 35
    ny = 7
    xmax = ${cc_spacer_radius}
    ymin = ${ram_spacer_height}
    ymax = ${ram_cc_spacers_height}
    boundary_name_prefix = 'bottom_cc_spacer'
    boundary_id_offset = 8
    elem_type = QUAD8
  []
  [bottom_cc_spacer_block]
    type = SubdomainIDGenerator
    input = 'bottom_cc_spacer'
    subdomain_id = '2'
  []
  [bottom_sinter_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 40
    ny = 27
    xmax = ${sinter_spacer_radius}
    ymin = ${ram_cc_spacers_height}
    ymax = ${ram_cc_sinter_spacers_height}
    boundary_name_prefix = bottom_sinter_spacer
    boundary_id_offset = 12
    elem_type = QUAD8
  []
  [bottom_sinter_overhang]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 27
    ny = 2
    xmin = ${fparse sinter_spacer_radius - sinter_spacer_overhang_radius}
    xmax = ${sinter_spacer_radius}
    ymin = ${ram_cc_sinter_spacers_height}
    ymax = ${fparse ram_cc_sinter_spacers_height + sinter_spacer_overhang_height}
    boundary_name_prefix = bottom_sinter_spacer_overhang
    elem_type = QUAD8
    boundary_id_offset = 16
  []
  [stitch_bottom_sinter_spacer]
    type = StitchedMeshGenerator
    inputs = 'bottom_sinter_spacer bottom_sinter_overhang'
    stitch_boundaries_pairs = 'bottom_sinter_spacer_top bottom_sinter_spacer_overhang_bottom'
  []
  [bottom_sinter_spacer_block]
    type = SubdomainIDGenerator
    input = 'stitch_bottom_sinter_spacer'
    subdomain_id = '3'
  []
  [bottom_punch]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 24
    xmax = ${punch_radius}
    ymin = ${ram_cc_sinter_spacers_height}
    ymax = ${ram_cc_sinter_punch_height}
    boundary_name_prefix = 'bottom_punch'
    elem_type = QUAD8
    boundary_id_offset = 20
  []
  [bottom_punch_block]
    type = SubdomainIDGenerator
    input = bottom_punch
    subdomain_id = 4
  []

  [powder]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 15
    ny = 18
    xmax = ${powder_radius}
    ymin = ${ram_cc_sinter_punch_height}
    ymax = ${stack_with_powder}
    boundary_name_prefix = powder
    elem_type = QUAD8
    boundary_id_offset = 24
  []
  [powder_block]
    type = SubdomainIDGenerator
    input = powder
    subdomain_id = 5
  []

  [top_punch]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 24
    xmax = ${punch_radius}
    ymin = ${stack_with_powder}
    ymax = ${fparse stack_with_powder + punch_height}
    boundary_name_prefix = 'top_punch'
    elem_type = QUAD8
    boundary_id_offset = 28
  []
  [top_punch_block]
    type = SubdomainIDGenerator
    input = top_punch
    subdomain_id = 6
  []
  [top_sinter_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 40
    ny = 27
    xmax = ${sinter_spacer_radius}
    ymin = ${fparse stack_with_powder + punch_height}
    ymax = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_cc_spacers_height}
    boundary_name_prefix = top_sinter_spacer
    boundary_id_offset = 32
    elem_type = QUAD8
  []
  [top_sinter_overhang]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 27
    ny = 2
    xmin = ${fparse sinter_spacer_radius - sinter_spacer_overhang_radius}
    xmax = ${sinter_spacer_radius}
    ymin = ${fparse stack_with_powder + punch_height - sinter_spacer_overhang_height}
    ymax = ${fparse stack_with_powder + punch_height}
    boundary_name_prefix = top_sinter_spacer_overhang
    elem_type = QUAD8
    boundary_id_offset = 36
  []
  [stitch_top_sinter_spacer]
    type = StitchedMeshGenerator
    inputs = 'top_sinter_spacer top_sinter_overhang'
    stitch_boundaries_pairs = 'top_sinter_spacer_bottom top_sinter_spacer_overhang_top'
  []
  [top_sinter_spacer_block]
    type = SubdomainIDGenerator
    input = 'stitch_top_sinter_spacer'
    subdomain_id = '7'
  []
  [top_cc_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 35
    ny = 7
    xmax = ${cc_spacer_radius}
    ymin = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_cc_spacers_height}
    ymax = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_spacer_height}
    boundary_name_prefix = 'top_cc_spacer'
    boundary_id_offset = 40
    elem_type = QUAD8
  []
  [top_cc_spacer_block]
    type = SubdomainIDGenerator
    input = 'top_cc_spacer'
    subdomain_id = '8'
  []
  [top_ram_spacer]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 31
    ny = 20
    xmax = ${ram_spacer_radius}
    ymin = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_spacer_height}
    ymax = ${fparse stack_with_powder + ram_cc_sinter_punch_height}
    boundary_name_prefix = top_ram_spacer
    elem_type = QUAD8
    boundary_id_offset = 44
  []
  [top_ram_overhang]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 2
    xmin = ${fparse ram_spacer_radius - ram_spacer_overhang_radius}
    xmax = ${ram_spacer_radius}
    ymin = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_spacer_height - ram_spacer_overhang_height}
    ymax = ${fparse stack_with_powder + ram_cc_sinter_punch_height - ram_spacer_height}
    boundary_name_prefix = top_ram_spacer_overhang
    elem_type = QUAD8
    boundary_id_offset = 48
  []
  [stitch_top_ram_spacer]
    type = StitchedMeshGenerator
    inputs = 'top_ram_spacer top_ram_overhang'
    stitch_boundaries_pairs = 'top_ram_spacer_bottom top_ram_spacer_overhang_top'
  []
  [top_ram_spacer_block]
    type = SubdomainIDGenerator
    input = 'stitch_top_ram_spacer'
    subdomain_id = '9'
  []

  [die_wall]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 14
    ny = 30
    xmin = ${die_wall_inner_radius}
    xmax = ${die_wall_outer_radius}
    ymin = ${fparse ram_cc_sinter_punch_height + (powder_height - die_wall_height) / 2.0}
    ymax = ${fparse ram_cc_sinter_punch_height + (powder_height + die_wall_height) / 2.0}
    boundary_name_prefix = die_wall
    elem_type = QUAD8
    boundary_id_offset = 52
  []
  [die_wall_block]
    type = SubdomainIDGenerator
    input = 'die_wall'
    subdomain_id = 10
  []

  [ten_blocks]
    type = MeshCollectionGenerator
    inputs = 'bottom_ram_spacer_block bottom_cc_spacer_block bottom_sinter_spacer_block
              bottom_punch_block powder_block top_punch_block top_sinter_spacer_block
              top_cc_spacer_block top_ram_spacer_block die_wall_block'
  []
  [block_rename]
    type = RenameBlockGenerator
    input = ten_blocks
    old_block = '1 2 3 4 5 6 7 8 9 10'
    new_block = 'bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer bottom_punch
                 powder top_punch top_sinter_spacer top_cc_spacer top_ram_spacer die_wall'
  []

  [bottom_ram_cc_primary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bottom_ram_spacer_top'
    new_block_id = 111
    new_block_name = 'bottom_ram_cc_primary_subdomain'
    input = block_rename
  []
  [bottom_ram_cc_secondary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bottom_cc_spacer_bottom'
    new_block_id = 212
    new_block_name = 'bottom_ram_cc_secondary_subdomain'
    input = bottom_ram_cc_primary_subdomain
  []
  [bottom_cc_sinter_primary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bottom_cc_spacer_top'
    new_block_id = 211
    new_block_name = 'bottom_cc_sinter_primary_subdomain'
    input = bottom_ram_cc_secondary_subdomain
  []
  [bottom_cc_sinter_secondary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bottom_sinter_spacer_bottom'
    new_block_id = 312
    new_block_name = 'bottom_cc_sinter_secondary_subdomain'
    input = bottom_cc_sinter_primary_subdomain
  []
  [bottom_sinter_punch_primary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bottom_sinter_spacer_top'
    new_block_id = 311
    new_block_name = 'bottom_sinter_punch_primary_subdomain'
    input = bottom_cc_sinter_secondary_subdomain
  []
  [bottom_sinter_punch_secondary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bottom_punch_bottom'
    new_block_id = 412
    new_block_name = 'bottom_sinter_punch_secondary_subdomain'
    input = bottom_sinter_punch_primary_subdomain
  []
  [bottom_punch_powder_primary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bottom_punch_top'
    new_block_id = 411
    new_block_name = 'bottom_punch_powder_primary_subdomain'
    input = bottom_sinter_punch_secondary_subdomain
  []
  [bottom_punch_powder_secondary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'powder_bottom'
    new_block_id = 512
    new_block_name = 'bottom_punch_powder_secondary_subdomain'
    input = bottom_punch_powder_primary_subdomain
  []

  [powder_top_punch_primary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'powder_top'
    new_block_id = 511
    new_block_name = 'powder_top_punch_primary_subdomain'
    input = bottom_punch_powder_secondary_subdomain
  []
  [powder_top_punch_secondary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_punch_bottom'
    new_block_id = 612
    new_block_name = 'powder_top_punch_secondary_subdomain'
    input = powder_top_punch_primary_subdomain
  []
  [top_punch_sinter_primary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_punch_top'
    new_block_id = 611
    new_block_name = 'top_punch_sinter_primary_subdomain'
    input = powder_top_punch_secondary_subdomain
  []
  [top_punch_sinter_secondary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_sinter_spacer_bottom'
    new_block_id = 712
    new_block_name = 'top_punch_sinter_secondary_subdomain'
    input = top_punch_sinter_primary_subdomain
  []
  [top_sinter_cc_primary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_sinter_spacer_top'
    new_block_id = 711
    new_block_name = 'top_sinter_cc_primary_subdomain'
    input = top_punch_sinter_secondary_subdomain
  []
  [top_sinter_cc_secondary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_cc_spacer_bottom'
    new_block_id = 812
    new_block_name = 'top_sinter_cc_secondary_subdomain'
    input = top_sinter_cc_primary_subdomain
  []
  [top_cc_ram_primary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_cc_spacer_top'
    new_block_id = 811
    new_block_name = 'top_cc_ram_primary_subdomain'
    input = top_sinter_cc_secondary_subdomain
  []
  [top_cc_ram_secondary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_ram_spacer_bottom'
    new_block_id = 912
    new_block_name = 'top_cc_ram_secondary_subdomain'
    input = top_cc_ram_primary_subdomain
  []

  [inside_die_primary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'die_wall_left'
    new_block_id = 1013
    new_block_name = 'inside_die_primary_subdomain'
    input = top_cc_ram_secondary_subdomain
  []
  [inside_low_punch_secondary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'bottom_punch_right'
    new_block_id = 414
    new_block_name = 'inside_low_punch_secondary_subdomain'
    input = inside_die_primary_subdomain
  []
  [inside_powder_secondary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'powder_right'
    new_block_id = 514
    new_block_name = 'inside_powder_secondary_subdomain'
    input = inside_low_punch_secondary_subdomain
  []
  [inside_top_punch_secondary_subdomain]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'top_punch_right'
    new_block_id = 614
    new_block_name = 'inside_top_punch_secondary_subdomain'
    input = inside_powder_secondary_subdomain
  []

  patch_update_strategy = iteration
  second_order = true
  coord_type = RZ
[]

[Problem]
  type = ReferenceResidualProblem
  reference_vector = 'ref'
  extra_tag_vectors = 'ref'
  converge_on = 'temperature potential'
[]

[Variables]
  [temperature]
    initial_condition = 300.0
    block = 'bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer bottom_punch
             powder top_punch top_sinter_spacer top_cc_spacer top_ram_spacer die_wall'
    order = SECOND
  []
  [potential]
    block = 'bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer bottom_punch
             powder top_punch top_sinter_spacer top_cc_spacer top_ram_spacer die_wall'
    order = SECOND
  []

  [temperature_bottom_ram_cc_lm]
    block = 'bottom_ram_cc_secondary_subdomain'
    order = SECOND
  []
  [potential_bottom_ram_cc_lm]
    block = 'bottom_ram_cc_secondary_subdomain'
    order = SECOND
  []
  [temperature_bottom_cc_sinter_lm]
    block = 'bottom_cc_sinter_secondary_subdomain'
    order = SECOND
  []
  [potential_bottom_cc_sinter_lm]
    block = 'bottom_cc_sinter_secondary_subdomain'
    order = SECOND
  []
  [temperature_bottom_sinter_punch_lm]
    block = 'bottom_sinter_punch_secondary_subdomain'
    order = SECOND
  []
  [potential_bottom_sinter_punch_lm]
    block = 'bottom_sinter_punch_secondary_subdomain'
    order = SECOND
  []
  [temperature_bottom_punch_powder_lm]
    block = ' bottom_punch_powder_secondary_subdomain'
    order = SECOND
  []
  [potential_bottom_punch_powder_lm]
    block = 'bottom_punch_powder_secondary_subdomain'
    order = SECOND
  []
  [temperature_powder_top_punch_lm]
    block = 'powder_top_punch_secondary_subdomain'
    order = SECOND
  []
  [potential_powder_top_punch_lm]
    block = ' powder_top_punch_secondary_subdomain'
    order = SECOND
  []
  [temperature_top_punch_sinter_lm]
    block = 'top_punch_sinter_secondary_subdomain'
    order = SECOND
  []
  [potential_top_punch_sinter_lm]
    block = 'top_punch_sinter_secondary_subdomain'
    order = SECOND
  []
  [temperature_top_sinter_cc_lm]
    block = 'top_sinter_cc_secondary_subdomain'
    order = SECOND
  []
  [potential_top_sinter_cc_lm]
    block = 'top_sinter_cc_secondary_subdomain'
    order = SECOND
  []
  [temperature_top_cc_ram_lm]
    block = 'top_cc_ram_secondary_subdomain'
    order = SECOND
  []
  [potential_top_cc_ram_lm]
    block = 'top_cc_ram_secondary_subdomain'
    order = SECOND
  []
  [temperature_inside_low_punch_lm]
    block = 'inside_low_punch_secondary_subdomain'
    order = SECOND
  []
  [potential_inside_low_punch_lm]
    block = 'inside_low_punch_secondary_subdomain'
    order = SECOND
  []
  [temperature_inside_powder_lm]
    block = 'inside_powder_secondary_subdomain'
    order = SECOND
  []
  [potential_inside_powder_lm]
    block = 'inside_powder_secondary_subdomain'
    order = SECOND
  []
  [temperature_inside_top_punch_lm]
    block = 'inside_top_punch_secondary_subdomain'
    order = SECOND
  []
  [potential_inside_top_punch_lm]
    block = 'inside_top_punch_secondary_subdomain'
    order = SECOND
  []
[]

[AuxVariables]
  [heat_transfer_radiation]
    order = SECOND
  []

  [electric_field_x]
    family = MONOMIAL #prettier pictures with smoother values
    order = FIRST
    block = 'bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer bottom_punch
             powder top_punch top_sinter_spacer top_cc_spacer top_ram_spacer die_wall'
  []
  [electric_field_y]
    family = MONOMIAL
    order = FIRST
    block = 'bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer bottom_punch
             powder top_punch top_sinter_spacer top_cc_spacer top_ram_spacer die_wall'
  []

  [interface_normal_lm]
    order = FIRST
    family = LAGRANGE
    block = 'bottom_ram_cc_secondary_subdomain bottom_cc_sinter_secondary_subdomain
             bottom_sinter_punch_secondary_subdomain bottom_punch_powder_secondary_subdomain
             powder_top_punch_secondary_subdomain top_punch_sinter_secondary_subdomain
             top_sinter_cc_secondary_subdomain top_cc_ram_secondary_subdomain
             inside_low_punch_secondary_subdomain inside_powder_secondary_subdomain
             inside_top_punch_secondary_subdomain'
    initial_condition = 1.0e6
  []
[]

[Kernels]
  [HeatDiff_graphite]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = graphite_thermal_conductivity
    extra_vector_tags = 'ref'
    block = 'bottom_ram_spacer bottom_sinter_spacer bottom_punch
             top_punch top_sinter_spacer top_ram_spacer die_wall'
  []
  [HeatTdot_graphite]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = graphite_heat_capacity
    density_name = graphite_density
    extra_vector_tags = 'ref'
    block = 'bottom_ram_spacer bottom_sinter_spacer bottom_punch
             top_punch top_sinter_spacer top_ram_spacer die_wall'
  []
  [electric_graphite]
    type = ADMatDiffusion
    variable = potential
    diffusivity = graphite_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'bottom_ram_spacer bottom_sinter_spacer bottom_punch
             top_punch top_sinter_spacer top_ram_spacer die_wall'
  []
  [JouleHeating_graphite]
    type = ADJouleHeatingSource
    variable = temperature
    elec = potential
    electrical_conductivity = graphite_electrical_conductivity
    # use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'bottom_ram_spacer bottom_sinter_spacer bottom_punch
             top_punch top_sinter_spacer top_ram_spacer die_wall'
  []

  # [HeatDiff_carbon_fiber]
  #   type = ADHeatConduction
  #   variable = temperature
  #   thermal_conductivity = ccfiber_thermal_conductivity
  #   extra_vector_tags = 'ref'
  #   block = 'bottom_cc_spacer top_cc_spacer'
  # []
  [HeatDiff_anistropic_carbon_fiber]
    type = ADMatAnisoDiffusion
    diffusivity = ccfiber_aniso_thermal_conductivity
    variable = temperature
    extra_vector_tags = 'ref'
    block = 'bottom_cc_spacer top_cc_spacer'
  []
  [HeatTdot_carbon_fiber]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = ccfiber_heat_capacity
    density_name = ccfiber_density
    extra_vector_tags = 'ref'
    block = 'bottom_cc_spacer top_cc_spacer'
  []
  [electric_carbon_fiber]
    type = ADMatDiffusion
    variable = potential
    diffusivity = ccfiber_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'bottom_cc_spacer top_cc_spacer'
  []
  [JouleHeating_carbon_fiber]
    type = ADJouleHeatingSource
    variable = temperature
    elec = potential
    electrical_conductivity = ccfiber_electrical_conductivity
    # use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'bottom_cc_spacer top_cc_spacer'
  []

  [HeatDiff_powder]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = copper_thermal_conductivity
    extra_vector_tags = 'ref'
    block = 'powder'
  []
  [HeatTdot_powder]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = copper_heat_capacity
    density_name = copper_density
    extra_vector_tags = 'ref'
    block = 'powder'
  []
  [electric_powder]
    type = ADMatDiffusion
    variable = potential
    diffusivity = copper_electrical_conductivity
    extra_vector_tags = 'ref'
    block = 'powder'
  []
  [JouleHeating_powder]
    type = ADJouleHeatingSource
    variable = temperature
    elec = potential
    electrical_conductivity = copper_electrical_conductivity
    # use_displaced_mesh = true
    extra_vector_tags = 'ref'
    block = 'powder'
  []
[]

[AuxKernels]
  [heat_transfer_radiation]
    type = ParsedAux
    variable = heat_transfer_radiation
    boundary = 'bottom_ram_spacer_right bottom_ram_spacer_overhang_right bottom_cc_spacer_right
                bottom_sinter_spacer_right bottom_sinter_spacer_overhang_right
                top_sinter_spacer_overhang_right top_sinter_spacer_right die_wall_right
                top_cc_spacer_right top_ram_spacer_overhang_right top_ram_spacer_right'
    # boundary = 'bottom_ram_spacer_right bottom_ram_spacer_overhang_right bottom_cc_spacer_right
    #             bottom_sinter_spacer_right bottom_sinter_spacer_overhang_right bottom_punch_right
    #             die_wall_right top_punch_right top_sinter_spacer_overhang_right top_sinter_spacer_right
    #             top_cc_spacer_right top_ram_spacer_overhang_right top_ram_spacer_right'
                coupled_variables = 'temperature'
    constant_names = 'boltzmann epsilon temperature_farfield' #published emissivity for graphite is 0.85
    constant_expressions = '5.67e-8 0.85 300.0' #roughly room temperature, which is probably too cold
    expression = '-boltzmann*epsilon*(temperature^4-temperature_farfield^4)'
  []

  [electrostatic_calculation_x]
    type = PotentialToFieldAux
    gradient_variable = potential
    variable = electric_field_x
    sign = negative
    component = x
    block = 'bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer bottom_punch
             powder top_punch top_sinter_spacer top_cc_spacer top_ram_spacer die_wall'
  []
  [electrostatic_calculation_y]
    type = PotentialToFieldAux
    gradient_variable = potential
    variable = electric_field_y
    sign = negative
    component = y
    block = 'bottom_ram_spacer bottom_cc_spacer bottom_sinter_spacer bottom_punch
             powder top_punch top_sinter_spacer top_cc_spacer top_ram_spacer die_wall'
  []
[]

[Functions]
  ## The current application function used here is a generalization of 13 Nov 2023 data
  [current_application]
    type = PiecewiseLinear
    x = '0.0 110     150    160    190    570    670    680    990    1010    1020    1100'
    y = '  0   0 ${fparse 518/ram_spacer_surface_area} ${fparse 521/ram_spacer_surface_area} ${fparse 253/ram_spacer_surface_area} ${fparse 691/ram_spacer_surface_area} ${fparse 693/ram_spacer_surface_area} ${fparse 716/ram_spacer_surface_area} ${fparse 721/ram_spacer_surface_area}   ${fparse 1/ram_spacer_surface_area}    0    0'
    scale_factor = 1.0
  []
  # [current_application]
  #   type = ParsedFunction
  #   expression = 'current_from_file/ ${ram_spacer_surface_area}'
  # []
[]

[BCs]
  [temperature_rams]
    type = ADDirichletBC
    variable = temperature
    value = 300.0
    boundary = 'top_ram_spacer_top bottom_ram_spacer_bottom'
  []
  [external_surface_temperature]
    type = CoupledVarNeumannBC
    variable = temperature
    v = heat_transfer_radiation
    boundary = 'bottom_ram_spacer_right bottom_ram_spacer_overhang_right bottom_cc_spacer_right
                bottom_sinter_spacer_right bottom_sinter_spacer_overhang_right
                top_sinter_spacer_overhang_right top_sinter_spacer_right die_wall_right
                top_cc_spacer_right top_ram_spacer_overhang_right top_ram_spacer_right'
  []
  [electric_top]
    type = ADFunctionNeumannBC
    variable = potential
    function = 'current_application'
    boundary = 'top_ram_spacer_top'
  []
  [electric_bottom]
    type = ADDirichletBC
    variable = potential
    value = 0.0
    boundary = 'bottom_ram_spacer_bottom'
  []
[]

[Constraints]
  [thermal_contact_interface_low_ram_cc_spacers]
    type = ModularGapConductanceConstraint
    variable = temperature_bottom_ram_cc_lm
    secondary_variable = temperature
    primary_boundary = bottom_ram_spacer_top
    primary_subdomain = bottom_ram_cc_primary_subdomain
    secondary_boundary = bottom_cc_spacer_bottom
    secondary_subdomain = bottom_ram_cc_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_bottom_ram_cc'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_ram_cc_low_spacers]
    type = ModularGapConductanceConstraint
    variable = potential_bottom_ram_cc_lm
    secondary_variable = potential
    primary_boundary = bottom_ram_spacer_top
    primary_subdomain = bottom_ram_cc_primary_subdomain
    secondary_boundary = bottom_cc_spacer_bottom
    secondary_subdomain = bottom_ram_cc_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_bottom_ram_cc'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_cc_sinter_low_spacers]
    type = ModularGapConductanceConstraint
    variable = temperature_bottom_cc_sinter_lm
    secondary_variable = temperature
    primary_boundary = bottom_cc_spacer_top
    primary_subdomain = bottom_cc_sinter_primary_subdomain
    secondary_boundary = bottom_sinter_spacer_bottom
    secondary_subdomain = bottom_cc_sinter_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_bottom_cc_sinter'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_cc_sinter_low_spacers]
    type = ModularGapConductanceConstraint
    variable = potential_bottom_cc_sinter_lm
    secondary_variable = potential
    primary_boundary = bottom_cc_spacer_top
    primary_subdomain = bottom_cc_sinter_primary_subdomain
    secondary_boundary = bottom_sinter_spacer_bottom
    secondary_subdomain = bottom_cc_sinter_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_bottom_cc_sinter'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_low_sinter_punch]
    type = ModularGapConductanceConstraint
    variable = temperature_bottom_sinter_punch_lm
    secondary_variable = temperature
    primary_boundary = bottom_sinter_spacer_top
    primary_subdomain = bottom_sinter_punch_primary_subdomain
    secondary_boundary = bottom_punch_bottom
    secondary_subdomain = bottom_sinter_punch_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_bottom_sinter_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_low_sinter_punch]
    type = ModularGapConductanceConstraint
    variable = potential_bottom_sinter_punch_lm
    secondary_variable = potential
    primary_boundary = bottom_sinter_spacer_top
    primary_subdomain = bottom_sinter_punch_primary_subdomain
    secondary_boundary = bottom_punch_bottom
    secondary_subdomain = bottom_sinter_punch_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_bottom_sinter_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_low_punch_powder]
    type = ModularGapConductanceConstraint
    variable = temperature_bottom_punch_powder_lm
    secondary_variable = temperature
    primary_boundary = bottom_punch_top
    primary_subdomain = bottom_punch_powder_primary_subdomain
    secondary_boundary = powder_bottom
    secondary_subdomain = bottom_punch_powder_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_bottom_punch_powder'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_low_punch_powder]
    type = ModularGapConductanceConstraint
    variable = potential_bottom_punch_powder_lm
    secondary_variable = potential
    primary_boundary = bottom_punch_top
    primary_subdomain = bottom_punch_powder_primary_subdomain
    secondary_boundary = powder_bottom
    secondary_subdomain = bottom_punch_powder_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_bottom_punch_powder'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_powder_top_punch]
    type = ModularGapConductanceConstraint
    variable = temperature_powder_top_punch_lm
    secondary_variable = temperature
    primary_boundary = powder_top
    primary_subdomain = powder_top_punch_primary_subdomain
    secondary_boundary = top_punch_bottom
    secondary_subdomain = powder_top_punch_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_powder_top_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_powder_top_punch]
    type = ModularGapConductanceConstraint
    variable = potential_powder_top_punch_lm
    secondary_variable = potential
    primary_boundary = powder_top
    primary_subdomain = powder_top_punch_primary_subdomain
    secondary_boundary = top_punch_bottom
    secondary_subdomain = powder_top_punch_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_powder_top_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_top_punch_sinter]
    type = ModularGapConductanceConstraint
    variable = temperature_top_punch_sinter_lm
    secondary_variable = temperature
    primary_boundary = top_punch_top
    primary_subdomain = top_punch_sinter_primary_subdomain
    secondary_boundary = top_sinter_spacer_bottom
    secondary_subdomain = top_punch_sinter_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_top_punch_sinter'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_top_punch_sinter]
    type = ModularGapConductanceConstraint
    variable = potential_top_punch_sinter_lm
    secondary_variable = potential
    primary_boundary = top_punch_top
    primary_subdomain = top_punch_sinter_primary_subdomain
    secondary_boundary = top_sinter_spacer_bottom
    secondary_subdomain = top_punch_sinter_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_top_punch_sinter'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_top_sinter_cc_spacers]
    type = ModularGapConductanceConstraint
    variable = temperature_top_sinter_cc_lm
    secondary_variable = temperature
    primary_boundary = top_sinter_spacer_top
    primary_subdomain = top_sinter_cc_primary_subdomain
    secondary_boundary = top_cc_spacer_bottom
    secondary_subdomain = top_sinter_cc_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_top_sinter_cc_spacer'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_top_sinter_cc_spacers]
    type = ModularGapConductanceConstraint
    variable = potential_top_sinter_cc_lm
    secondary_variable = potential
    primary_boundary = top_sinter_spacer_top
    primary_subdomain = top_sinter_cc_primary_subdomain
    secondary_boundary = top_cc_spacer_bottom
    secondary_subdomain = top_sinter_cc_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_top_sinter_cc_spacer'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_top_cc_ram_spacers]
    type = ModularGapConductanceConstraint
    variable = temperature_top_cc_ram_lm
    secondary_variable = temperature
    primary_boundary = top_cc_spacer_top
    primary_subdomain = top_cc_ram_primary_subdomain
    secondary_boundary = top_ram_spacer_bottom
    secondary_subdomain = top_cc_ram_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_thermal_interface_top_cc_ram_spacer'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_top_cc_ram_spacers]
    type = ModularGapConductanceConstraint
    variable = potential_top_cc_ram_lm
    secondary_variable = potential
    primary_boundary = top_cc_spacer_top
    primary_subdomain = top_cc_ram_primary_subdomain
    secondary_boundary = top_ram_spacer_bottom
    secondary_subdomain = top_cc_ram_secondary_subdomain
    gap_geometry_type = PLATE
    gap_flux_models = 'closed_electric_interface_top_cc_ram_spacer'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_inside_die_low_punch]
    type = ModularGapConductanceConstraint
    variable = temperature_inside_low_punch_lm
    secondary_variable = temperature
    primary_boundary = die_wall_left
    primary_subdomain = inside_die_primary_subdomain
    secondary_boundary = bottom_punch_right
    secondary_subdomain = inside_low_punch_secondary_subdomain
    gap_geometry_type = CYLINDER
    gap_flux_models = 'thermal_conduction_wall_low_punch closed_thermal_interface_inside_die_low_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_inside_die_low_punch]
    type = ModularGapConductanceConstraint
    variable = potential_inside_low_punch_lm
    secondary_variable = potential
    primary_boundary = die_wall_left
    primary_subdomain = inside_die_primary_subdomain
    secondary_boundary = bottom_punch_right
    secondary_subdomain = inside_low_punch_secondary_subdomain
    gap_geometry_type = CYLINDER
    gap_flux_models = 'electrical_conduction_wall_low_punch closed_electric_interface_inside_die_low_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_inside_die_powder]
    type = ModularGapConductanceConstraint
    variable = temperature_inside_powder_lm
    secondary_variable = temperature
    primary_boundary = die_wall_left
    primary_subdomain = inside_die_primary_subdomain
    secondary_boundary = powder_right
    secondary_subdomain = inside_powder_secondary_subdomain
    gap_geometry_type = CYLINDER
    gap_flux_models = 'thermal_conduction_wall_powder closed_thermal_interface_inside_die_powder'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_inside_die_powder]
    type = ModularGapConductanceConstraint
    variable = potential_inside_powder_lm
    secondary_variable = potential
    primary_boundary = die_wall_left
    primary_subdomain = inside_die_primary_subdomain
    secondary_boundary = powder_right
    secondary_subdomain = inside_powder_secondary_subdomain
    gap_geometry_type = CYLINDER
    gap_flux_models = 'electrical_conduction_wall_powder closed_electric_interface_inside_die_powder'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [thermal_contact_interface_inside_die_top_punch]
    type = ModularGapConductanceConstraint
    variable = temperature_inside_top_punch_lm
    secondary_variable = temperature
    primary_boundary = die_wall_left
    primary_subdomain = inside_die_primary_subdomain
    secondary_boundary = top_punch_right
    secondary_subdomain = inside_top_punch_secondary_subdomain
    gap_geometry_type = CYLINDER
    gap_flux_models = 'thermal_conduction_wall_top_punch closed_thermal_interface_inside_die_top_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
  [electrical_contact_interface_inside_die_top_punch]
    type = ModularGapConductanceConstraint
    variable = potential_inside_top_punch_lm
    secondary_variable = potential
    primary_boundary = die_wall_left
    primary_subdomain = inside_die_primary_subdomain
    secondary_boundary = top_punch_right
    secondary_subdomain = inside_top_punch_secondary_subdomain
    gap_geometry_type = CYLINDER
    gap_flux_models = 'electrical_conduction_wall_top_punch closed_electric_interface_inside_die_top_punch'
    extra_vector_tags = 'ref'
    correct_edge_dropping = true
    # use_displaced_mesh = true
  []
[]

[Materials]
  [graphite_electro_thermal_properties]
    type = ADGenericConstantMaterial
    prop_names = 'graphite_density graphite_thermal_conductivity graphite_heat_capacity graphite_electrical_conductivity graphite_hardness'
    prop_values = ' 1.82e3               81                           1.5e3                   5.88e4                           1.0' #from G535 datasheet
    block = 'bottom_ram_spacer bottom_sinter_spacer bottom_punch
             top_punch top_sinter_spacer top_ram_spacer die_wall
             bottom_cc_sinter_secondary_subdomain bottom_sinter_punch_secondary_subdomain
             top_punch_sinter_secondary_subdomain top_cc_ram_secondary_subdomain
             inside_low_punch_secondary_subdomain inside_top_punch_secondary_subdomain'
  []
  [carbon_fiber_electro_thermal_properties]
    type = ADGenericConstantMaterial
    prop_names = 'ccfiber_density ccfiber_thermal_conductivity ccfiber_heat_capacity ccfiber_electrical_conductivity ccfiber_hardness'
    prop_values = ' 1.5e3                 5                         1.5e3                   5.88e4                           1.0' #from CF datasheet (Schunk CFC - Fibra de carbon.pdf)
    block = 'bottom_cc_spacer top_cc_spacer bottom_ram_cc_secondary_subdomain
             top_sinter_cc_secondary_subdomain'
  []
  [carbon_fiber_anisotropic_thermal_cond]
    # type = ADGenericConstantRankTwoTensor
    # tensor_name = ccfiber_aniso_thermal_conductivity
    # # tensor values are column major-ordered
    # tensor_values = '40.0 0 0 0 5.0 0 0 0 40.0'
    type = ADConstantAnisotropicMobility
    tensor = '40 0 0
              0  5 0
              0  0 40'
    M_name = ccfiber_aniso_thermal_conductivity
  []
  [copper_electro_thermal_properties]
    type = ADGenericConstantMaterial
    prop_names = 'copper_density copper_thermal_conductivity copper_heat_capacity copper_electrical_conductivity copper_hardness'
    prop_values = ' 8.96e3            401.2                     0.385e3             5.8e7                      1.0'
    # density (kg/m^3) and heat capacity (J/kg-K) from Stevens and Boerio-Goates. J. Chem. Thermodaynamics 36(10) 857-863(2004)
    # thermal conductivity (W/m-K) and electrical conductivity (S) from Moore, McElroy, and Graves. Cand. J. Phys 45 3849-3865 (1967).
    block = 'powder bottom_punch_powder_secondary_subdomain powder_top_punch_secondary_subdomain
             inside_powder_secondary_subdomain'
  []
[]

[UserObjects]
  [closed_thermal_interface_bottom_ram_cc]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = ccfiber_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = ccfiber_hardness
    boundary = bottom_cc_spacer_bottom
  []
  [closed_electric_interface_bottom_ram_cc]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = ccfiber_electrical_conductivity
    temperature = potential
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = ccfiber_hardness
    boundary = bottom_cc_spacer_bottom
  []
  [closed_thermal_interface_bottom_cc_sinter]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = ccfiber_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_normal_lm
    primary_hardness = ccfiber_hardness
    secondary_hardness = graphite_hardness
    boundary = bottom_sinter_spacer_bottom
  []
  [closed_electric_interface_bottom_cc_sinter]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = ccfiber_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = interface_normal_lm
    primary_hardness = ccfiber_hardness
    secondary_hardness = graphite_hardness
    boundary = bottom_sinter_spacer_bottom
  []
  [closed_thermal_interface_bottom_sinter_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = bottom_punch_bottom
  []
  [closed_electric_interface_bottom_sinter_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = bottom_punch_bottom
  []
  [closed_thermal_interface_bottom_punch_powder]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = copper_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = copper_hardness
    boundary = powder_bottom
  []
  [closed_electric_interface_bottom_punch_powder]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = copper_electrical_conductivity
    temperature = potential
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = copper_hardness
    boundary = powder_bottom
  []
  [closed_thermal_interface_powder_top_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = copper_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = copper_hardness
    boundary = top_punch_bottom
  []
  [closed_electric_interface_powder_top_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = copper_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = interface_normal_lm
    primary_hardness = copper_hardness
    secondary_hardness = graphite_hardness
    boundary = top_punch_bottom
  []
  [closed_thermal_interface_top_punch_sinter]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_sinter_spacer_bottom
  []
  [closed_electric_interface_top_punch_sinter]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_sinter_spacer_bottom
  []
  [closed_thermal_interface_top_sinter_cc_spacer]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = ccfiber_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = ccfiber_hardness
    boundary = top_cc_spacer_bottom
  []
  [closed_electric_interface_top_sinter_cc_spacer]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = ccfiber_electrical_conductivity
    temperature = potential
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = ccfiber_hardness
    boundary = top_cc_spacer_bottom
  []
  [closed_thermal_interface_top_cc_ram_spacer]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_ram_spacer_bottom
  []
  [closed_electric_interface_top_cc_ram_spacer]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_ram_spacer_bottom
  []

  [thermal_conduction_wall_low_punch]
    type = GapFluxModelConduction
    temperature = temperature
    boundary = bottom_punch_right
    gap_conductivity = 5  #ceramaterials, through thickness
    # use_displaced_mesh = true
  []
  [electrical_conduction_wall_low_punch]
    type = GapFluxModelConduction
    temperature = potential
    boundary = bottom_punch_right
    gap_conductivity = 1.429e5  #from ceramaterials datasheet, converted from resistivity
    # use_displaced_mesh = true
  []
  [closed_thermal_interface_inside_die_low_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = bottom_punch_right
  []
  [closed_electric_interface_inside_die_low_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = bottom_punch_right
  []
  [thermal_conduction_wall_powder]
    type = GapFluxModelConduction
    temperature = temperature
    boundary = powder_right
    gap_conductivity = 5  #ceramaterials, through thickness
    # use_displaced_mesh = true
  []
  [electrical_conduction_wall_powder]
    type = GapFluxModelConduction
    temperature = potential
    boundary = powder_right
    gap_conductivity = 1.429e5  #from ceramaterials datasheet, converted from resistivity
    # use_displaced_mesh = true
  []
  [closed_thermal_interface_inside_die_powder]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = copper_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = copper_hardness
    boundary = powder_right
  []
  [closed_electric_interface_inside_die_powder]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = copper_electrical_conductivity
    temperature = potential
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = copper_hardness
    boundary = powder_right
  []
  [thermal_conduction_wall_top_punch]
    type = GapFluxModelConduction
    temperature = temperature
    boundary = top_punch_right
    gap_conductivity = 5  #ceramaterials, through thickness
    # use_displaced_mesh = true
  []
  [electrical_conduction_wall_top_punch]
    type = GapFluxModelConduction
    temperature = potential
    boundary = top_punch_right
    gap_conductivity = 1.429e5  #from ceramaterials datasheet, converted from resistivity
    # use_displaced_mesh = true
  []
  [closed_thermal_interface_inside_die_top_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_thermal_conductivity
    secondary_conductivity = graphite_thermal_conductivity
    temperature = temperature
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_punch_right
  []
  [closed_electric_interface_inside_die_top_punch]
    type = GapFluxModelPressureDependentConduction
    primary_conductivity = graphite_electrical_conductivity
    secondary_conductivity = graphite_electrical_conductivity
    temperature = potential
    contact_pressure = interface_normal_lm
    primary_hardness = graphite_hardness
    secondary_hardness = graphite_hardness
    boundary = top_punch_right
  []
[]

[Postprocessors]
  [applied_current]
    type = FunctionValuePostprocessor
    function = current_application
  []

  [pyrometer_point]
    type = PointValue
    variable = temperature
    point = '0.01375 ${fparse ram_cc_sinter_punch_height + powder_height / 2.0} 0'
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
  solve_type = NEWTON
  automatic_scaling = false
  line_search = 'none'

  # mortar contact solver options
  petsc_options = '-snes_converged_reason -pc_svd_monitor'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_type'
  petsc_options_value = ' lu       superlu_dist'
  snesmf_reuse_base = false

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  nl_max_its = 20
  nl_forced_its = 2
  l_max_its = 50

  start_time = 110
  dtmax = 10
  end_time = 1200
[]

[Outputs]
  color = false
  csv = true
  exodus = true
  perf_graph = true
[]
