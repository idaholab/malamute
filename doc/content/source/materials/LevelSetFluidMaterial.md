# Level set fluid material

!syntax description /Materials/LevelSetFluidMaterial

## Description

The gas and solid-liquid phases are separated by the interface and their properties are smoothly change across the interface. Density $\rho$ and dynamic viscosity $\mu$ in the transition region are expressed as:

\begin{equation}
\rho=(1-H)\rho_m+H\rho_g,
\end{equation}

\begin{equation}
\mu=(1-H)\mu_m+H\mu_g,
\end{equation}
where $H$ is the Heaviside function, subscripts $m$ and $g$ denote metal and gas, respectively.

## Example Input Syntax

!listing test/tests/melt_pool_fluid/fluid.i block=Materials/fluid

!syntax parameters /Materials/LevelSetFluidMaterial

!syntax inputs /Materials/LevelSetFluidMaterial

!syntax children /Materials/LevelSetFluidMaterial
