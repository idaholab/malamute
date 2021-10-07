# Mushy zone material

!syntax description /Materials/MushyZoneMaterial

## Description

The solid-liquid region consists of three phases, solid, liquid and mushy zone (solid-liquid mixture). The corresponding mushy zone properties are defined as

\begin{equation}
\rho_m = g_s\rho_s+g_l\rho_l
\end{equation}

\begin{equation}
h_m = f_sh_s + f_l h_l
\end{equation}

\begin{equation}
c_m = f_sc_s + f_lc_l
\end{equation}

\begin{equation}
k_m = \left( \frac{g_s}{k_s}+\frac{g_l}{k_l}\right)^{-1}
\end{equation}

\begin{equation}
\mu_m=\mu_l\frac{\rho_m}{\rho_l}
\end{equation}
where subscripts $s$ and $l$ denote solid and liquid, respectively. $c_s$ and $c_l$ are solid and liquid metal heat capacity, respectively, and $g_s$ and $g_l$ are the solid and liquid volume fraction, respectively. Their relationships are given by
\begin{equation}
g_l=\frac{f_l}{\rho_l}\left( \frac{1-f_l}{\rho_s}+\frac{f_l}{\rho_l}\right)^{-1},
\end{equation}

\begin{equation}
g_s=1-\frac{f_l}{\rho_l}\left( \frac{1-f_l}{\rho_s}+\frac{f_l}{\rho_l}\right)^{-1}.
\end{equation}

## Example Input Syntax

!listing test/tests/melt_pool_heat/thermal_material.i block=Materials/mushy

!syntax parameters /Materials/MushyZoneMaterial

!syntax inputs /Materials/MushyZoneMaterial

!syntax children /Materials/MushyZoneMaterial
