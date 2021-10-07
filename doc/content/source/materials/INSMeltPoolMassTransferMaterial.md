# Mass transfer rate due to liquid-vapor phase change

!syntax description /Materials/INSMeltPoolMassTransferMaterial

## Description

The mass transfer rate $\dot{m}$ [!citep](Courtois2014) is described by
\begin{equation}
\dot{m}=\sqrt{\frac{m}{2\pi k_b}}\frac{p_{sat}(T)}{\sqrt{T}}(1-\beta_r),
\end{equation}
where $m$ is the atomic weight, $k_b$ is the Boltzmann constant, $\beta_r$ the retrodiffusion coefficient and $p_{sat}(T)$ is the saturated vapor pressure given by
\begin{equation}
p_{sat}(T)=p_0\exp\left[\frac{mL_v}{k_b T_{vap}}\left(1-\frac{T_{vap}}{T} \right) \right],
\end{equation}
where $p_o$ is reference temperature, $L_v$ is the latent heat of vaporization and $T_{vap}$ is the vaporization temperature.

## Example Input Syntax

!listing test/tests/melt_pool_fluid/fluid.i block=Materials/mass_transfer

!syntax parameters /Materials/INSMeltPoolMassTransferMaterial

!syntax inputs /Materials/INSMeltPoolMassTransferMaterial

!syntax children /Materials/INSMeltPoolMassTransferMaterial
