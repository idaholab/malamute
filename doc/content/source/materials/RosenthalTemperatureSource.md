# Rosenthal temperature source material

!syntax description /Materials/RosenthalTemperatureSource

## Description

This material implements the Rosenthal equation for meltpool geometry [!cite](Rosenthal1946). The temperature profile is defined as:
\begin{equation}
T(x,r)=T_0 + \frac{\lambda P}{2 \pi k_T r} \exp\left[{- \frac{V(r+x)}{2 \alpha}}\right],
\end{equation}
where $T_0$ is the ambient temperature, $P$ is the laser power, $\lambda$ is the power absorption coefficient, $k_T$ is the thermal conductivity, $\alpha$ is the thermal diffusivity, and $V$ is the scanning velocity. Here, $r$ is the radial distance from the heat source defined as $r = \sqrt{x^2+y^2+z^2}$, where x, y, z, are the positional coordinates within the moving reference frame. The laser heat source is assumed to move in x direction such that the position x is updated with $(x-x_0-Vt)$, where $x_0$ is the initial position coordinate at $t=0$.

The meltpool depth and width is calculated as follows:

\begin{equation}
D \approx \sqrt{\frac{2 \lambda P}{ \pi e \rho C_p V (T_m-T_0)}}\, ,
\end{equation}
\begin{equation}
W = 2 D,
\end{equation}
where $T_m$ is the melting temperature, $\rho$ is the density, and $C_p$ is the specific heat.

## Example Input Syntax

!listing test/tests/melt_pool_geometry/rosenthal_temp_source.i block=Materials/meltpool

!syntax parameters /Materials/RosenthalTemperatureSource

!syntax inputs /Materials/RosenthalTemperatureSource

!syntax children /Materials/RosenthalTemperatureSource
