# StainlessSteelThermal

!syntax description /Materials/StainlessSteelThermal

## Description

This material computes the thermal conductivity, in W/(m-K), and the specific
heat capacity, in J/(k-kg), for AISI 304 stainless steel based on the material
properties given for a spark plasma sintering die in [!citep](cincotti2007sps).
These thermal material properties are computed only as a function of
temperature, T. The thermal conductivity is calculated as
\begin{equation}
  \label{eqn:thermal_conductivity}
  k = 0.0144 T + 10.55
\end{equation}
with a calibration range of 310.6 to 1032.5K.

The heat capacity calibration range is 120.8 to 1494.9K, and the relationship is
given as a piecewise function:
\begin{equation}
  \label{eqn:heat_capacity}
  C_p = 2.484 \times 10^{-7} T^3 - 7.321 \times 10^{-4} T^2 + 0.840 T + 253.7
\end{equation}
The most conservative calibration limits from the thermal conductivity are
enforced within the code.

The relationships for these thermal material properties were determined through
curve fits to the experimental data points shown in [!citep](cincotti2007sps)
and do not completely match the curve fit relationships given in that work. The
curve fits used in this class are shown in [fig:steel_thermal_conductivity] and [fig:steel_heat_capacity].

!media media/systems/materials/StainlessSteel_thermalConductivity_curvefit.png
    id=fig:steel_thermal_conductivity
    caption=Polynomial relationship for AISI 304 stainless steel thermal conductivity as a function of temperature, with the curve fit shown against the experimental data points.
    style=display:block;margin-left:auto;margin-right:auto;width:70%

!media media/systems/materials/StainlessSteel_heatCapacity_curvefit.png
    id=fig:steel_heat_capacity
    caption=Polynomial relationship for the heat capacity of AISI 304 stainless steel, shown with the coefficient of determination and the experimental data points.
    style=display:block;margin-left:auto;margin-right:auto;width:70%

The local temperature is checked against the calibration range limits only once
at the start of each timestep, using the value of the temperature from the
previous converged timestep. The values of thermal conductivity and heat capacity
are, however, calculated with the current value of the temperature.

## Example Input File Syntax

!listing test/tests/materials/stainless_steel/thermal/ad_stainless_steel_thermal_material_properties.i block=Materials/stainless_steel_thermal


!syntax parameters /Materials/StainlessSteelThermal

!syntax inputs /Materials/StainlessSteelThermal

!syntax children /Materials/StainlessSteelThermal
