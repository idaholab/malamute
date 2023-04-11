# Function Path Gaussian Heat Source

This class creates a Gaussian heat source [!citep](yushu2022directed) (see [ADGaussianHeatSourceBase](ADGaussianHeatSourceBase.md) for more information) whose center follows user specified path along three directions. The spatial location of the heat source center $\boldsymbol{p}(\boldsymbol{x},t)$ is decomposed along three directions, i.e.,
\begin{equation}
  \boldsymbol{p}(\boldsymbol{x}, t) = [ p_x(t), p_y(t), p_y(t)],
\end{equation}
where $p_x(t), p_y(t), p_y(t)$ are user defined time-varying spatial locations along three directions.


!listing test/tests/gaussian_heat_source/gaussian_heat_source.i block=Materials/volumetric_heat

!syntax parameters /Materials/ADFunctionPathGaussianHeatSource

!syntax inputs /Materials/ADFunctionPathGaussianHeatSource

!syntax children /Materials/ADFunctionPathGaussianHeatSource

!bibtex bibliography
