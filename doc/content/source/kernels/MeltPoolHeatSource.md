# Melt pool heat source

!syntax description /Kernels/MeltPoolHeatSource

## Description

The energy conservation equation[!citep](ShaoyiWen2010) is described by

\begin{equation}
\rho\frac{\partial h}{\partial t}+ \rho\nabla \cdot (\overrightarrow{u}h) = \nabla\cdot(k\nabla T) + Q,
\end{equation}
where $Q$ is the source term, consisting of laser heat source and heat loss flux at the interface
\begin{equation}
Q = \frac{2P\alpha}{\pi R_b^2}\exp\left(\frac{-2r^2}{R_b^2}\right)|\nabla\phi| -A_h(T-T_0)|\nabla\phi| -\sigma\epsilon(T^4-T_0^4)|\nabla\phi|,
\end{equation}
where the three terms on the right represent heat flux from the laser, heat losses through convection and radiation, respectively.

## Example Input Syntax

!listing test/tests/melt_pool_heat/heat.i block=Kernels/heat_source

!syntax parameters /Kernels/MeltPoolHeatSource

!syntax inputs /Kernels/MeltPoolHeatSource

!syntax children /Kernels/MeltPoolHeatSource
