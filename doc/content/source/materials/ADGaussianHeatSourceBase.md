# Gaussian Heat Source

This is a material base class for generating a time and spatially varying heat source that mimics the scanning laser beam, which is often observed in the Directed Energy Deposition (DED) process. Three heat source formulations are available in this class.

### Point heat source

Specifically, this class offers the option to use the classic Gaussian point heat source $\hat{Q}$, which has been widely used for laser heat source modeling (e.g., [!citep](michaleris2014modeling,denlinger2017thermomechanical)):
\begin{equation}
\label{eqn:point_heat_source}
\hat{Q}(\boldsymbol{x}, t) = \frac{2\alpha\eta P}{\pi r^3} \exp \left\{ - \frac{2||| \boldsymbol{x} - \boldsymbol{p}(t) ||^2}{r^2} \right\},
\end{equation}
where $P$ is the laser power, $\alpha$ is the equipment-related scaling factor, $\eta$ is the laser efficiency coefficient, $r$ denotes the effective radius of the laser beam, $||\cdot||$ denotes the Euclidean norm, and $\boldsymbol{p}(t)\in \mathbb{R}^3$ denotes the scanning path, which is a time-varying spatial location that represents the movement of the laser beam.

### Line heat source

The Gaussian point heat source ($\hat{Q}(\boldsymbol{x}, t)$) in Eqn. [eqn:point_heat_source] can skip over some elements when the time step size, $\Delta t$, is too big (i.e., $\Delta t > r∕v$, $v$ the scanning speed). To resolve this issue, we offer an option to use the Gaussian line heat source ($\bar{Q}$), which was proposed in [!citep](irwin2016line),
\begin{equation}
\label{eqn:line_heat_source}
\bar{Q}(\boldsymbol{x}, t) = \frac{1}{\Delta t} \int_{t_0}^{t_0 + \Delta t} \hat{Q}(\boldsymbol{x}, t) \text{d}t,
\end{equation}
where $t_0$ is the time at the beginning of the time step. Here, $\bar{Q}$ is the time-average of $\hat{Q}$, such that $lim_{\Delta t \to 0} \bar{Q} = \hat{Q}$.

### Hybrid heat source

A third option is the hybrid Gaussian heat source $Q$, which is proposed to mitigate numerical inaccuracies by using the line heat source, and enables enlarged time step size. The hybrid Gaussian heat source switches between the Gaussian point heat source model and Gaussian line heat source model as follows [!citep](yushu2022directed):
\begin{equation}
\label{eqn:hybrid_heat_source}
Q(\boldsymbol{x}, t) =
\begin{cases}
& \hat{Q}(\boldsymbol{x}, t)~\quad t<\Delta t~\text{or}~||\boldsymbol{p}(t)-\boldsymbol{p}(t-\Delta t)||\leq L_0,\\
& \bar{Q}(\boldsymbol{x}, t)~\quad \text{otherwise}.\\
\end{cases}
\end{equation}
The $L_0$ is the threshold distance between the current laser spot location and the laser spot location at the previous time step; below this threshold the point heat source is to be applied instead of the line average heat source.

### Scanning path

For all three heat source formulations above, the scanning path $\boldsymbol{p}(t)$ is a time-varying spatial location that represents the movement of the laser beam. Therefore, $\boldsymbol{p}(t)$ is  dependent on the product geometry and processing parameters, including scanning pattern, scanning speed, hatch spacing, and layer thickness, etc.

Users can specify the velocity profile or the spacial location of the laser beam using [ADVelocityGaussianHeatSource](ADVelocityGaussianHeatSource.md) or [ADFunctionPathGaussianHeatSource](ADFunctionPathGaussianHeatSource.md).

### Effective radii

One can choose to explicitly specify the effective radii of the laser spot directly in the input file. Another choice is to use the value that is calculated from the following relationship:
\begin{equation}
\begin{split}
r_x \sim \mathcal{N}(\bar{r}_x, \sigma^2_{x}),\quad r_y \sim \mathcal{N}(\bar{r}_y, \sigma^2_{y}),\quad r_z \sim \mathcal{N}(\bar{r}_z, \sigma^2_{z}),
\end{split}
\end{equation}
where $\bar{r}_x, \bar{r}_y, \bar{r}_z$ and $\sigma^2_{x}, \sigma^2_{y}, \sigma^2_{z}$ are functions of laser power ($P$), scanning speeds, and feed rates. The relations are obtained through parameterizing a second order formulation using experimentally measured data.

!bibtex bibliography
