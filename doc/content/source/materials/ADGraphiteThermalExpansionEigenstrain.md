# ADGraphiteThermalExpansionEigenstrain

!syntax description /Materials/ADGraphiteThermalExpansionEigenstrain

## Description

This material computes the coefficient of thermal expansion, in 1/K, for AT 101
graphite based on the material properties given for a spark plasma
sintering die in [!citep](cincotti2007sps) using automatic differentiation.
The coefficient of thermal expansion value is computed solely as a function of
temperature, T:
\begin{equation}
  \label{eqn:coeffient_thermal_expansion}
  \alpha = 1.996 \times 10^{-6} log \left(4.799 \times 10^{-2} T \right) - 4.041 \times 10^{-6}
\end{equation}
where the calibration range is 290.9K to 2383.0K.

The relationship for this thermal material property was set as a piecewise
function with constant values based on the experimental data points
[!citep](cincotti2007sps), as shown in [fig:graphite_coefficient_thermal_expansion].

!media media/systems/materials/Graphite_thermalExpansion_curvefit.png
    id=fig:graphite_coefficient_thermal_expansion
    caption=Shown against the experimental data points, the coefficient of thermal expansion for AT 101 graphite is fit as a a logarithmic function.
    style=display:block;margin-left:auto;margin-right:auto;width:70%


The local temperature is checked against the calibration range limits only once
at the start of each timestep, using the value of the temperature from the
previous converged timestep. The value of the coefficient of thermal expansion
is calculated with the current value of the temperature.

## Example Input File Syntax

!listing test/tests/materials/graphite/mechanical/ad_graphite_thermal_expansion.i block=Materials/graphite_thermal_expansion


!syntax parameters /Materials/ADGraphiteThermalExpansionEigenstrain

!syntax inputs /Materials/ADGraphiteThermalExpansionEigenstrain

!syntax children /Materials/ADGraphiteThermalExpansionEigenstrain
