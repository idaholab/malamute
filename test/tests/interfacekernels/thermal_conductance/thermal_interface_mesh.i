# Mesh block used to generate thermal_interface_regular_mesh.e and thermal_interface_jacobian_mesh.e
# To generate meshes, select appropriate ix, iy below and use the --mesh-only flag when running this input file.

[Mesh]
  [assembly]
    type = CartesianMeshGenerator
    dim = 2
    dx = '0.04 0.01'
    dy = '0.255 0.005 0.005 0.07 0.005 0.005 0.159'
    # ix = '2 1'              # to generate Jacobian mesh
    # iy = '1 1 1 1 1 1 1'
    ix = '5 1'                # to generate regular mesh
    iy = '32 12 2 9 2 12 20'
    subdomain_id = '1 3
                    1 3
                    2 4
                    2 4
                    2 4
                    1 3
                    1 3' # this is the top of the mesh
  []
  [create_interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = assembly
    master_block = 1
    paired_block = 2
    new_boundary = 'ssg_interface'
  []
  [rename_boundaries]
    type = RenameBoundaryGenerator
    input = create_interface
    old_boundary_name = 'top bottom'
    new_boundary_name = 'top_die bottom_die'
  []
  [rename_blocks]
    type = RenameBlockGenerator
    input = rename_boundaries
    old_block = '1 2'
    new_block = 'stainless_steel graphite'
  []
  [rename_stainless_steel_sideset]
    type = BlockDeletionGenerator
    input = rename_blocks
    block_id = 3
    new_boundary = 'right_stainless_steel'
  []
  [rename_graphite_sideset]
    type = BlockDeletionGenerator
    input = rename_stainless_steel_sideset
    block_id = 4
    new_boundary = 'right_graphite'
  []
[]
