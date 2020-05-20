# CoupledSimpleRadiativeHeatFluxBC

!syntax description /BCs/CoupledSimpleRadiativeHeatFluxBC

## Description

This boundary condition computes the radiative heat flux from the specified
boundary to an assumed surrounding blackbody:

\begin{equation}
   \dot{Q} = \sum_i \left[ \alpha_i \epsilon_i \sigma \left( T^4 - T^4_{infinity}\right) \right]
\end{equation}
where $\alpha_i$ is the weight of the components of the body present on the
boundary, $\epsilon_i$ is the emissivity of each component, and $\sigma$ is the
Boltzmann constant [!citep](modest2013radiative).

## Example Input File Syntax

!listing multiple_phases_simple_radiation.i block=BCs/heatloss


!syntax parameters /BCs/CoupledSimpleRadiativeHeatFluxBC

!syntax inputs /BCs/CoupledSimpleRadiativeHeatFluxBC

!syntax children /BCs/CoupledSimpleRadiativeHeatFluxBC
