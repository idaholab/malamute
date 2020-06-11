# ThermalContactCondition

!syntax description /InterfaceKernels/ThermalContactCondition

## Description

This interface kernel models the conductivity of heat flux across a specified
boundary between two dissimilar materials, as described by [!citep](cincotti2007sps).
It accounts for the influence of both temperature and electrostatic potential
differences across the interface, with appropriate thermal and electrical
contact conductances being provided by the user as a constant scalar number. The
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
- $f$ is the splitting factor of the Joule heat source arising from electrical contact resistance (default is 0.5).

## Example Input File Syntax

!listing thermal_interface.i block=InterfaceKernels/thermal_contact_conductance


!syntax parameters /InterfaceKernels/ThermalContactCondition

!syntax inputs /InterfaceKernels/ThermalContactCondition

!syntax children /InterfaceKernels/ThermalContactCondition
