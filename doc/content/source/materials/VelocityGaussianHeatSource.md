# Velocity Gaussian Heat Source

This class creates a Gaussian heat source [!citep](yushu2022directed) (see [GaussianHeatSourceBase](GaussianHeatSource.md) for more information) which moves at specified speed profiles along three directions. The spatial location of the heat source center $\boldsymbol{p}(\boldsymbol{x},t)$ can be decomposed along three directions:
\begin{equation}
  p_x(t) = x_0 + \int_{0}^{t} v_x(t) \text{d}t,\quad
  p_y(t) = y_0 + \int_{0}^{t} v_y(t) \text{d}t,\quad
  p_z(t) = z_0 + \int_{0}^{t} v_z(t) \text{d}t,
\end{equation}
where $(x_0, y_0,z_0)$ represents the initial location, and $(v_x(t), v_y(t), v_z(t))$ denotes the time-varying velocity of the heat source center, respectively.

## Example Input File

!listing test/tests/gaussian_heat_source/velocity_gaussian_heat_source.i block=Materials/volumetric_heat

!syntax parameters /Materials/VelocityGaussianHeatSource

!syntax inputs /Materials/VelocityGaussianHeatSource

!syntax children /Materials/VelocityGaussianHeatSource

!bibtex bibliography
