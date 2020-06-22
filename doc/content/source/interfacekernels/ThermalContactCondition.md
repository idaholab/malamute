# ThermalContactCondition

!syntax description /InterfaceKernels/ThermalContactCondition

## Description

This interface kernel models the conductivity of heat flux across a specified
boundary between two dissimilar materials, as described by [!citep](cincotti2007sps).
It accounts for the influence of both temperature and electrostatic potential
differences across the interface, with appropriate thermal and electrical
contact conductances being provided by the user as a constant scalar number or
via a combination of material properties and constants for calculation. The
condition being applied is:

\begin{equation}
  -k_1 \frac{\partial T}{\partial \mathbf{r}} \bigg\rvert_1 \cdot \mathbf{\hat{n}} = C_T (T_1 - T_2) - f C_E (\phi_1 - \phi_2)^2
\end{equation}

\begin{equation}
  -k_2 \frac{\partial T}{\partial \mathbf{r}} \bigg\rvert_2 \cdot \mathbf{\hat{n}} = C_T (T_1 - T_2) + (1 - f) C_E (\phi_1 - \phi_2)^2
\end{equation}

where

- $k_i$ is the thermal conductivity of each material along the interface,
- $C_T$ is the thermal contact conductance,
- $C_E$ is the electrical contact conductance,
- $T_i$ is the temperature of the material at the interface,
- $\phi_i$ is the electrostatic potential of the material at the interface, and
- $f$ is the splitting factor of the Joule heat source arising from electrical
  contact resistance (default is 0.5). This parameter sets the fraction of heat
  flux associated with Joule heating that enters the primary side of the
  boundary, with the rest entering the secondary side.

### Thermal Contact Conductance

The temperature- and mechanical-pressure-dependent thermal contact conductance,
given by [!citep](madhusadana1996), is calculated using:

\begin{equation}
  C_T(T, P) = \alpha_T k_{el,Harm} \bigg( \frac{P}{H_{Harm}} \bigg)^{\beta_T}
\end{equation}

where

- $\alpha_T$ is an experimentally-derived proportional fit parameter (set to be
  $22,810$, from [!citep](cincotti2007sps)),
- $k_{el,Harm}$ is the harmonic mean of the temperature-dependent thermal
  conductivities on either side of the boundary,
- $P$ ($=F/S$) is the uniform mechanical pressure applied at the contact surface
  area (S) between the two materials,
- $H_{Harm}$ is the harmonic mean of the hardness values of each material, and
- $\beta_T$ is an experimentally-derived power fit parameter (set to be $1.08$,
  from [!citep](cincotti2007sps)).

### Electrical Contact Conductance

The temperature- and mechanical-pressure-dependent electrical contact
conductance, given by [!citep](babu2001contactresistance), is calculated using:

\begin{equation}
  C_E(T, P) = \alpha_E \sigma_{el,Harm} \bigg( \frac{P}{H_{Harm}} \bigg)^{\beta_E}
\end{equation}

where

- $\alpha_E$ is an experimentally-derived proportional fit parameter (set to be
  $64$, from [!citep](cincotti2007sps)),
- $\sigma_{el,Harm}$ is the harmonic mean of the temperature-dependent electrical
  conductivities on either side of the boundary,
- $P$ ($=F/S$) is the uniform mechanical pressure applied at the contact surface
  area (S) between the two materials,
- $H_{Harm}$ is the harmonic mean of the hardness values of each material, and
- $\beta_E$ is an experimentally-derived power fit parameter (set to be $0.35$,
  from [!citep](cincotti2007sps)).

### Geometric Mean

For reference, the harmonic mean calculation for two values, $V_a$ and $V_b$, is
given by:

\begin{equation}
  V_{Harm} = \frac{2 V_a V_b}{V_a + V_b}
\end{equation}

## Example Input File Syntax

### Calculated Conductance

!listing thermal_interface.i block=InterfaceKernels/thermal_contact_conductance_calculated

### Supplied Conductance

!listing thermal_interface.i block=InterfaceKernels/thermal_contact_conductance

!syntax parameters /InterfaceKernels/ThermalContactCondition

!syntax inputs /InterfaceKernels/ThermalContactCondition

!syntax children /InterfaceKernels/ThermalContactCondition
