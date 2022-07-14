# ADCoupledSimpleRadiativeHeatFluxBC

!syntax description /BCs/ADCoupledSimpleRadiativeHeatFluxBC

## Description

This boundary condition computes the radiative heat flux from the specified
boundary to an assumed surrounding blackbody. This boundary condition accounts for
the effect of different phases present in the body, such as multiple microstructure
phases or precipitates, by summing the heat transfer as a function of the fraction
of each phase:

\begin{equation}
   \dot{Q} = \sum_i \left[ \alpha_i \epsilon_i \sigma \left( T^4 - T^4_{infinity}\right) \right]
\end{equation}
where $\alpha_i$ is the fraction of the phases present in the body on the
boundary, $\epsilon_i$ is the emissivity of each component, and $\sigma$ is the
Boltzmann constant [!citep](cangel2002thermodynamics). Note that the user is
responsible for ensuring that the values of the $\alpha$ components sum to unity.

## Example Input File Syntax

!listing multiple_phases_simple_radiation.i block=BCs/heatloss


!syntax parameters /BCs/ADCoupledSimpleRadiativeHeatFluxBC

!syntax inputs /BCs/ADCoupledSimpleRadiativeHeatFluxBC

!syntax children /BCs/ADCoupledSimpleRadiativeHeatFluxBC
