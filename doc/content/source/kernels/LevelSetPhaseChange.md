# LevelSetPhaseChange

!syntax description /Kernels/LevelSetPhaseChange

## Description

This kernel implements third term in the level set evolution equation given below
\begin{equation}
\frac{\partial\phi}{\partial t} + \overrightarrow{u}\dot\nabla\phi - \dot{m}\delta(\phi)\left(\frac{\phi}{\rho_g}-\frac{1-\phi}{\rho_l}\right) = 0,
\end{equation}
where $\dot{m}$ is mass transfer rate ([INSMeltPoolMassTransferMaterial](/INSMeltPoolMassTransferMaterial.md)) and $\rho_g$ and $\rho_l$ are gas density and liquid density, respectively.

## Example Syntax

!listing test/tests/melt_pool_level_set/level_set.i block=Kernels/level_set_phase_change

!syntax parameters /Kernels/LevelSetPhaseChange

!syntax inputs /Kernels/LevelSetPhaseChange

!syntax children /Kernels/LevelSetPhaseChange
