# LevelSetPowderAddition

!syntax description /Kernels/LevelSetPowderAddition

## Description

In the level set evolution equation, the free surface growth velocity due to the powder addition is given as [!citep](Morville2012),

\begin{equation}
V_p = N_p \frac{{\eta}_p D_m}{{\rho}_0 \pi r_p^2}\exp\left(-N_p\frac{r^2}{r_p^2}\right),
\end{equation}
where $N_p$ and $r_P$ are the constriction coefficient and the standard deviation of the gaussian distribution. The $r$ is the radial distance. The $\eta_p$ is the powder catchment efficiency. The $\rho_0$ is the powder density. The $D_m$ is the mass powder rate.

## Example Input Syntax

!listing test/tests/melt_pool_mass/mass.i block=Kernels/level_set_mass

!syntax parameters /Kernels/LevelSetPowderAddition

!syntax inputs /Kernels/LevelSetPowderAddition

!syntax children /Kernels/LevelSetPowderAddition
