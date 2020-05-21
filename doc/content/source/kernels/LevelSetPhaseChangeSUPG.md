# LevelSetPhaseChangeSUPG

!syntax description /Kernels/LevelSetPhaseChangeSUPG

## Description

This kernel adds the Streamline Upwind/Petrov-Galerkin (SUPG) stabilization term [!citep](brooks1982streamline, donea2003finite) to third term term of a partial differential equation in the level set evolution equation given below
\begin{equation}
\frac{\partial\phi}{\partial t} + \overrightarrow{u}\dot\nabla\phi - \dot{m}\delta(\phi)\left(\frac{\phi}{\rho_g}-\frac{1-\phi}{\rho_l}\right) = 0,
\end{equation}
where $\dot{m}$ is mass transfer rate ([INSMeltPoolMassTransferMaterial](/INSMeltPoolMassTransferMaterial.md)) and $\rho_g$ and $\rho_l$ are gas density and liquid density, respectively.

The stabliation term is given as
\begin{equation}
\label{eq:LevelSetForcingFunctionSUPG:weak}
\left(\tau \vec{v} \psi_i,\, \dot{m}\delta(\phi)\left(\frac{\phi}{\rho_g}-\frac{1-\phi}{\rho_l}\right)\right) = 0,
\end{equation}
where $\vec{v}$ is the level set velocity and $\tau$ as defined below.

\begin{equation}
\label{eq:LevelSetForcingFunctionSUPG:tau}
\tau = \frac{h}{2\|\vec{v}\|},
\end{equation}
where $h$ is the element length.

## Example Syntax

!listing test/tests/melt_pool_level_set/level_set.i block=Kernels/level_set_phase_change_supg

!syntax parameters /Kernels/LevelSetPhaseChangeSUPG

!syntax inputs /Kernels/LevelSetPhaseChangeSUPG

!syntax children /Kernels/LevelSetPhaseChangeSUPG
