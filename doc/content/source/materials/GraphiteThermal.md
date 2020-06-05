# GraphiteThermal

!syntax description /Materials/GraphiteThermal

## Description

This material computes the thermal conductivity, in W/(m-K), and the specific
heat capacity, in J/(k-kg), for AT 101 graphite based on the material properties
given for an spark plasma sintering die in [!citep](cincotti2007sps). These
thermal material properties are computed only as a function of temperature, T.
The thermal conductivity is calculated as
\begin{equation}
  \label{eqn:thermal_conductivity}
  k = 1.519 \times 10^{-5} T^2 - 8.007 \times 10^{-2} T + 130.2
\end{equation}
with a calibration range of 268.9 to 3312 K.

The heat capacity calibration range is 495.5 to 4097.7K, and the relationship is
given as a piecewise function:
\begin{equation}
  \label{eqn:heat_capacity}
  C_p = \begin{cases}
    3.852 \times 10^{-7} T^3 - 1.921 \times 10^{-3} T^2 + 3.318 T + 16.282  & \text{ if } T < 2004 K  \\
    5.878 \times 10^{-2} T + 1931.166 & \text{ if } T \geq 2004 K
  \end{cases}
\end{equation}
The most conservative calibration limits are enforced within the code.

The computation of these properties occurs only once at the start of each
timestep. This design decision significantly improves the computational
efficiency of the class; however, the value of the temperature from the previous
converged timestep is used to compute the thermal conductivity and heat capacity
values for the current timestep.

The relationships for these thermal material properties were determined through
curve fits to the experimental data points shown in [!citep](cincotti2007sps)
and do not completely match the curve fit relationships given in that work. The
curve fits used in this class are shown in [fig:graphite_thermal_conductivity],
[fig:graphite_lowtemp_heatcapacity], and [fig:graphite_hightemp_heatcapacity].

!media media/systems/materials/Graphite_thermalConductivity_curvefit.png
    id=fig:graphite_thermal_conductivity
    caption=Polynomial relationship for thermal conductivity as a function of temperature, with the curve fit shown against the experimental data points.
    style=display:block;margin-left:auto;margin-right:auto;width:70%

!media media/systems/materials/Graphite_heatCapacity_LowerRange_curvefit.png
    id=fig:graphite_lowtemp_heatcapacity
    caption=Polynomial relationship for the heat capacity of AT 101 graphite below 2004 K shown with the coefficient of determination and the experimental data points.
    style=display:block;margin-left:auto;margin-right:auto;width:70%

!media media/systems/materials/Graphite_heatCapacity_UpperRange_curvefit.png
    id=fig:graphite_hightemp_heatcapacity
    caption=Shown against the experimental data points, the heat capacity of AT 101 graphite is fit as a linear relationship of temperature above 2004K.
    style=display:block;margin-left:auto;margin-right:auto;width:70%



## Example Input File Syntax

!listing test/tests/materials/graphite/graphite_thermal_material_properties.i block=Materials/graphite_thermal


!syntax parameters /Materials/GraphiteThermal

!syntax inputs /Materials/GraphiteThermal

!syntax children /Materials/GraphiteThermal
