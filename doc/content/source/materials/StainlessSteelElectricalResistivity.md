# StainlessSteelElectricalResistivity

!syntax description /Materials/StainlessSteelElectricalResistivity

## Description

This material computes the electrical resistivity, in $\Omega$/m, for AISI 304
stainless steel based on the material properties given for a spark plasma
sintering die in [!citep](cincotti2007sps). This electrical material property is
computed solely as a function of temperature, T:
\begin{equation}
  \label{eqn:electrical_resistivity}
  k = 1.575 \times 10^{-15} T^3 - 3.236 \times 10^{-12} T^2 + 2.724 \times 10^{-9} T + 1.364 \times 10^{-7}
\end{equation}
with a calibration range of 296.8 to 1029K.

The relationship for this thermal material property was determined with a curve
fit to the experimental data points shown in [!citep](cincotti2007sps). As such,
the polynomial fit shown in [eqn:electrical_resistivity] does not fully  match
the curve fit relationships given in that work. The curve fit used in this class
is shown in [fig:steel_electrical_resistivity].

!media media/systems/materials/StainlessSteel_electricalResistivity_curvefit.png
    id=fig:steel_electrical_resistivity
    caption=Polynomial relationship for the electrical resistivity of AISI 304 stainless steel, shown with the coefficient of determination and the experimental data points.
    style=display:block;margin-left:auto;margin-right:auto;width:70%


The local temperature is checked against the calibration range limits only once
at the start of each timestep, using the value of the temperature from the
previous converged timestep. The value of the electrical resistivity is,
however, calculated with the current value of the temperature.

## Example Input File Syntax

!listing test/tests/materials/stainless_steel/electrical/stainless_steel_electrical_material_properties.i block=Materials/stainless_steel_electrical


!syntax parameters /Materials/StainlessSteelElectricalResistivity

!syntax inputs /Materials/StainlessSteelElectricalResistivity

!syntax children /Materials/StainlessSteelElectricalResistivity
