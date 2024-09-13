!content pagination previous=introduction/tutorial_overview.md
                    next=introduction/required_input_file_modifications.md
                    margin-bottom=0px

## Input File Content

The six key parts of an input file are as follows: `[Mesh], [Variables], [Kernels], [BCs], [Executioner], and [Outputs]`. This guide is an overview of what elements to modify (or not modify) within these parts to run an electrothermal simulation with the desired parameters. A key term to keep in mind is “block.” The six key parts as mentioned earlier are considered high-level blocks and will be referred to as blocks for the remainder of this guide. View the [MOOSE Workshop](https://mooseframework.inl.gov/workshop/#/) to explore these six parts in greater detail. The majority of this input file is presented as a template, and only a few lines of the input file will need to be modified for the purposes of this tutorial. The full input file is available within the MALAMUTE github repository:

!listing !listing tutorials/efas/introduction/dcs5_copper_constant_properties_electrothermal.i

The `Mesh` block maps out and displays the geometry of the distinct sections of the EFAS tooling stack, as described in the [tutorial_overview.md] +Motivation+ section, that are shown in open-source data visualization software such as [ParaView](https://www.paraview.org). The `[Problem]` block sets up the handling of numerical convergence. Please do not modify any values in the `[Mesh]` and `[Problem]` blocks as to allow for easier understanding of the tutorial.

The `[Variables]` block has two parts of note, in particular the `[temperature]` and `[potential]` blocks:

!listing tutorials/efas/introduction/dcs5_copper_constant_properties_electrothermal.i
         block=Variables
         link=False

The initial condition value of 300 K should remain as such. Also, understand that temperature and potential will be showcased in ParaView. While the remaining “_lm” listings are shown in `[Variables]`, these variables are associated with the many interfaces within the simulation. These variables will not be included directly in the analyses performed in this tutorial, and more information on these variables and their use in the Constraint system is available [here](https://mooseframework.inl.gov/syntax/Constraints/).

`[AuxVariables]` contains a block that applies boundary conditions related to heat transfer and includes a block that displays pictures of the electric field with smoother values.

!listing tutorials/efas/introduction/dcs5_copper_constant_properties_electrothermal.i
         block=AuxVariables
         link=False

The `[Kernels]` block uses the same equation for diffusion of temperature and diffusion of electric potential. The goal of this block is to couple temperature and electrical physics with joule heating. There are 12 sub-blocks inside the high-level `[Kernel]` block which are named according to the material it supports. For example, there are four out of twelve sub-blocks that include graphite in their name and include temperature diffusion (“HeatDiff_graphite”), electric potential diffusion (“electric_graphite”), and joule heating (“JouleHeating_graphite”).

!listing tutorials/efas/introduction/dcs5_copper_constant_properties_electrothermal.i
         block=Kernels
         link=False

The `[AuxKernels]` block contains a sub-block (“heat_transfer_radiation”) from the `[AuxVariables]` block that applies radiation heat loss boundary conditions on the external right side of spacers and die wall, as well as on the external right side of punches when uncovered. Constant expressions are also included in the `[AuxKernels]` block, such as graphite emissivity and initial temperature.

!listing tutorials/efas/introduction/dcs5_copper_constant_properties_electrothermal.i
         block=AuxKernels
         link=False

Current from the DCS-5 sintering machine is generalized in the `[Functions]` block. Please note a few aspects of the Neumann boundary condition. It is a function of time and is generalized from an uninsulated, 20 mm G535 graphite tooling DCS-5 run. Also, the Neumann boundary condition is the current divided by the surface area of the top surface of the top ram spacer.

!listing tutorials/efas/introduction/dcs5_copper_constant_properties_electrothermal.i
         block=Functions
         link=False

The `[BCs]` block sets the temperature and electrical boundary conditions on various parts of the sintering machine. For example, the ("temperature_rams") sub-block sets the edge of the top ram spacer and the edge of the bottom ram spacer to 300 K.

!listing tutorials/efas/introduction/dcs5_copper_constant_properties_electrothermal.i
         block=BCs
         link=False

The `[Constraints]` block is meant to specify contact interfaces and should remain unmodified throughout the tutorial.

!listing tutorials/efas/introduction/dcs5_copper_constant_properties_electrothermal.i
         block=Constraints
         link=False

All three materials (copper, graphite, C-C fiber) involved with the EFAS machine are described in the `[Materials]` block. Property values for each the materials are constant values as opposed to variable values, as shown in the "carbon_fiber_electro_thermal_properties" sub-block, for example. In the same sub-block, at `prop_values`, note the value for `ccfiber_thermal_conductivity`. The value “5” is the thermal conductivity of the C-C fiber in the y direction. This “5” value is the same as the middle value in the tensor matrix shown below under the sub-block titled “carbon_fiber_anisotropic_thermal_cond”. This matrix is a representation of anisoptropic thermal conductivity of C-C fiber.

!listing tutorials/efas/introduction/dcs5_copper_constant_properties_electrothermal.i
         block=Materials/carbon_fiber_electro_thermal_properties
         link=False

The `[UserObjects]` block is used for contact models and should remain untouched for the tutorial’s ease of use. When opening an output csv file, the `[Postprocessors]` block allows for a better understanding of boundary conditions by exporting the data to a program such as Excel. The "pyrometer_point" sub-block under the `[Postprocessors]` block points to where the pyrometer reads temperature at the end of the view hole.

!listing tutorials/efas/introduction/dcs5_copper_constant_properties_electrothermal.i
         block=Postprocessors
         link=False

`[Preconditioning]` and `[Executioner]` blocks are typically used for numerical convergence and for the sake of this tutorial, should remain unmodified. The `[Outputs]` block should also remain unmodified and simply exists to display data in Excel and ParaView.

!listing tutorials/efas/introduction/dcs5_copper_constant_properties_electrothermal.i
         block=Outputs
         link=False

Now that we are familiar with the sections of an input file, we are ready to make changes to the input file.

!content pagination previous=introduction/tutorial_overview.md
                    next=introduction/required_input_file_modifications.md
                    margin-bottom=0px
