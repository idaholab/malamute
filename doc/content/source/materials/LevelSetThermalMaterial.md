# Level set thermal material

!syntax description /Materials/LevelSetThermalMaterial

## Description

The gas and solid-liquid phases are separated by the interface and their properties are smoothly change across the interface. Density $\rho$, enthalpy $h$, thermal conductivity $k$ and dynamic viscosity $\mu$ in the transition region are expressed as:

\begin{equation}
\rho=(1-H)\rho_m+H\rho_g,
\end{equation}

\begin{equation}
h=(1-H)h_m+Hh_g,
\end{equation}

\begin{equation}
k=(1-H)k_m+Hk_g,
\end{equation}

\begin{equation}
\mu=(1-H)\mu_m+H\mu_g,
\end{equation}
where $H$ is the Heaviside function, subscripts $m$ and $g$ denote metal and gas, respectively.

## Example Input Syntax

!listing test/tests/melt_pool_heat/thermal_material.i block=Materials/thermal

!syntax parameters /Materials/LevelSetThermalMaterial

!syntax inputs /Materials/LevelSetThermalMaterial

!syntax children /Materials/LevelSetThermalMaterial
