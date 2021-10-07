# Melt pool INS residual material

!syntax description /Materials/INSMeltPoolMaterial

## Description

The momentum conservation equations[!citep](ShaoyiWen2010) are described by

\begin{equation}
\rho\left(\frac{\partial{\overrightarrow {u}}}{\partial t}+ \overrightarrow{u}\cdot{\nabla\overrightarrow {u}}\right)- \nabla\left [ -p\mathbf{I}+\mu\left(\nabla\overrightarrow {u} + \nabla \overrightarrow u ^T\right) \right ] =  -\frac{\mu_m}{K}\overrightarrow{u} + \gamma\overrightarrow {n} \kappa \delta(\phi)-\nabla_s\gamma\delta(\phi).
\end{equation}

The first term on the right is a Darcy term, representing the damping force when fluid passes through mushy zone. $K$ is the isotropic permeability given by
\begin{equation}
K^{-1}=K_0^{-1}\frac{(1-f_l)^2}{f_l^3+\tau},
\end{equation}
where $K_0$ and $\tau$ are constants and $f_l$ is fluid mass fraction.

The second and third terms represent surface tension and Marangoni forces at the free surfaces. The surface tension acts in the normal direction while Marangoni force acts in the tangential direction of the free surface. The surface gradient is expressed as
\begin{equation}
\nabla_s\gamma = \gamma_T\nabla_sT = \gamma_T (\mathbf{I}-\overrightarrow n \otimes \overrightarrow n)\nabla T.
\end{equation}

The mass conservation equation[!citep](ShaoyiWen2010, ESMAEELI2004) is modified to account for the phase change from liquid to vapor:
\begin{equation}
\nabla\cdot \overrightarrow {u} = \dot{m}\delta(\phi)\left(\frac{1}{\rho_g}-\frac{1}{\rho_l}\right),
\end{equation}
where $\dot{m}$ is mass transfer rate ([INSMeltPoolMassTransferMaterial](/INSMeltPoolMassTransferMaterial.md)) and $\rho_g$ and $\rho_l$ are gas density and liquid density, respectively. 

## Example Input Syntax

!listing test/tests/melt_pool_fluid/fluid.i block=Materials/ins_melt_pool_mat

!syntax parameters /Materials/INSMeltPoolMaterial

!syntax inputs /Materials/INSMeltPoolMaterial

!syntax children /Materials/INSMeltPoolMaterial
