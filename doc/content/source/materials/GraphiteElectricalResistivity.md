# GraphiteElectricalResistivity

!syntax description /Materials/GraphiteElectricalResistivity

## Description

This material computes the electrical resistivity, in $\Omega$/m, for AT 101
graphite based on the material properties given for an spark plasma sintering
die in [!citep](cincotti2007sps). This electrical material property is computed
solely as a function of temperature, T:
\begin{equation}
  \label{eqn:electrical_resistivity}
  k = -2.705 \times 10^{-15} T^3 + 1.263 \times 10^{-11} T^2 - 1.836 \times 10^{-8} T + 1.813 \times 10^{-5}
\end{equation}
with a calibration range of 291.7 to 1873.6K.

The relationship for this thermal material property was determined with a curve
fit to the experimental data points shown in [!citep](cincotti2007sps). As such,
the polynomial fit shown in [eqn:electrical_resistivity] does not fully  match
the curve fit relationships given in that work. The curve fit used in this class
is shown in [fig:graphite_electrical_resistivity].

!media media/systems/materials/Graphite_electricalResistivity_curvefit.png
    id=fig:graphite_electrical_resistivity
    caption=Polynomial relationship for the electrical resistivity of AT 101 graphite, shown with the coefficient of determination and the experimental data points.
    style=display:block;margin-left:auto;margin-right:auto;width:70%

The local temperature is checked against the calibration range limits only once
at the start of each timestep, using the value of the temperature from the
previous converged timestep. The electrical resistivity value is, however,
calculated with the current value of the temperature.

## Example Input File Syntax

!listing test/tests/materials/graphite/graphite_electrical_material_properties.i block=Materials/graphite_electrical


!syntax parameters /Materials/GraphiteElectricalResistivity

!syntax inputs /Materials/GraphiteElectricalResistivity

!syntax children /Materials/GraphiteElectricalResistivity
