# Melt pool INS momentum source kernel

!syntax description /Kernels/INSMeltPoolMomentumSource

## Description

The residual in the weak form is given by
\begin{equation}
R_i =  -\psi_i(-\frac{\mu_m}{K}\overrightarrow{u} + \gamma\overrightarrow {n} \kappa \delta(\phi)-\nabla_s\gamma\delta(\phi)),
\end{equation}
where $\psi_i$ is the test function.

## Example Input Syntax

!listing test/tests/melt_pool_fluid/fluid.i block=Kernels/melt_pool_momentum_source

!syntax parameters /Kernels/INSMeltPoolMomentumSource

!syntax inputs /Kernels/INSMeltPoolMomentumSource

!syntax children /Kernels/INSMeltPoolMomentumSource
