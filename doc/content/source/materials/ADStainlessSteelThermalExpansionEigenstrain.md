# ADADStainlessSteelThermalExpansionEigenstrain

!syntax description /Materials/ADStainlessSteelThermalExpansionEigenstrain

## Description

This material computes the coefficient of thermal expansion, in 1/K, for AISI 304
stainless steel based on the material properties given for a spark plasma
sintering die in [!citep](cincotti2007sps). The coefficient of thermal expansion
value is computed solely as a function of temperature, T:
\begin{equation}
  \label{eqn:coeffient_thermal_expansion}
  \alpha = \begin{cases}
    1.72 \times 10^{-5} & \text{ if } 273.3 < T < 373 K  \\
    1.78 \times 10^{-5} & \text{ if } 373 \leq T < 588 K  \\
    1.84 \times 10^{-5} & \text{ if } 588 \leq T < 810.5 K
  \end{cases}
\end{equation}
where the calibration range is 273.3 to 810.5K.

The relationship for this thermal material property was set as a piecewise
function with constant values based on the experimental data points
[!citep](cincotti2007sps), as shown in [fig:steel_coefficient_thermal_expansion].

!media media/systems/materials/StainlessSteel_thermalExpansion_curvefit.png
    id=fig:steel_coefficient_thermal_expansion
    caption=Piecewise constant values for the coefficient of thermal expansion for AISI 304 stainless steel.
    style=display:block;margin-left:auto;margin-right:auto;width:70%


The local temperature is checked against the calibration range limits only once
at the start of each timestep, using the value of the temperature from the
previous converged timestep. The value of the coefficient of thermal expansion
is calculated with the current value of the temperature.

## Example Input File Syntax

!listing test/tests/materials/stainless_steel/mechanical/ad_stainless_steel_thermal_expansion.i block=Materials/stainless_steel_thermal_expansion


!syntax parameters /Materials/ADStainlessSteelThermalExpansionEigenstrain

!syntax inputs /Materials/ADStainlessSteelThermalExpansionEigenstrain

!syntax children /Materials/ADStainlessSteelThermalExpansionEigenstrain
