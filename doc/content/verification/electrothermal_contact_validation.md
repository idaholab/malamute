# Electrothermal Validation

This document attempts to couple heat conduction and electrostatic physics to compare the results of EFAS simulations conducted using MALAMUTE and COMSOL. Below is a description of the summary of the sample cases involved and the necessary physics used in the tests. 

## Introduction

After verifying that the electrostatic [Electrostatic Contact, Two Blocks](verification/electrostatic_contact_two_block.md) contact resistance model for this simulation is working correctly, the electrothermal model outlined in [Heat Conduction Tutorial] (introduction/therm_step01.md) can be implemented in the sample cases outlined by Cincotti: [!citep](cincotti2007sps). The physics behind the electromagnetic and heat conduction modules in MOOSE will be used to model EFAS techniques described in Cincotti and introduce thermal contact and material definitions, based on findings from [!citep](cincotti2007sps). 

The sample cases are summarized below:

!media media/electrothermal_veri_images/sample_one.png
    style=width:80%;margin-left:auto;margin-right:auto;
    id=sample_one
    caption=Represents the two big spacers configuration in both Samples I and II. 

!media media/electrothermal_veri_images/sample_three.png
    style=width:80%;margin-left:auto;margin-right:auto;
    id=sample_three
    caption=Represents the two big spacers, two small spacers, and one plunger configuration in Sample III.

!media media/electrothermal_veri_images/sample_four.png
    style=width:80%;margin-left:auto;margin-right:auto;
    id=sample_four
    caption=Represents the two big spacers, two small spacers, one die and plungers configuration in Sample IV.

Here is a cross-section visual of the SPS system:

!media media/electrothermal_veri_images/sps_schematic.png
    style=width:80%;margin-left:auto;margin-right:auto;
    id=sps_schematic
    caption=Schematic from [!citep](cincotti2007sps).


The simulation cases to verify Cincotti’s data showcase various arrangements of graphite spacer and plunger layouts, which are set between two electrodes. The spacer and plunger components are real parts used in an experiment and the most complicated case is a situation in which the powder compact is removed. 

These are the three input files used in MALAMUTE for this verification case and can be found at `malamute/test/tests/example_testing`:

!listing sample_one.i

!listing sample_three.i

!listing sample_four.i

### Heat Conduction Physics

The transient heat conduction equation shown below models the flow of heat throughout a material domain. 

\begin{equation}
\begin{aligned}
\rho (t,\mathbf{r}) c (t,r) &= nabla k (t,\mathbf{r}) nabla T + dot{q}
\end{aligned}
\end{equation}

- $T$ is the temperature of the domain,
- $t$ is the time,
- $r$ is a spatial coordinate vector,
- $\rho$ is the material density,
- $c$ is the specific heat capacity,
- $k$ is the thermal conductivity,
- dot{q} is a heat source.

This convection boundary condition is used to simulate the heat loss via cooling water and is along the surface of the water channel within each stainless-steel electrode. 

\begin{equation}
\begin{aligned}
\k_S nabla T \mathbf{\hat{n}} &= h (T - T_0)
\end{aligned}
\end{equation}

- $k_S$ is the thermal conductivity of stainless steel,
- $h$ is the heat transfer coefficient for the cooling water,
- $T_0$ is the background temperature of the water.

For vacuum-facing surfaces, a radiative boundary condition (simulating radiation from a “grey body”) was applied, given by:

\begin{equation}
\begin{aligned}
\k_i nabla T \mathbf{\hat{n}} &= eta_i nu (T^4 - T_0^4)
\end{aligned}
\end{equation}

Thermal contact [ThermalContactCondition.md] between interfaces of the same material were considered perfectly continuous, such that between two identical materials A and B with heat conductive across an interface in the z direction, the condition is given by:

\begin{equation}
\begin{aligned}
\frac{\partial phi}{\partial x} \bigg\rvert_A &= \frac{\partial phi}{\partial z} \bigg\rvert_B
\end{aligned}
\end{equation}

- where $i$ is either stainless steel or graphite,
- $eta_i$ is the emissivity of the material,
- $nu$ is the Stefan-Boltzmann constant.

### Electrostatic Physics

Electric fields inside the medium are electrostatic because SPS/EFAS is a DC process. A Poisson’s equation is used to model the electrostatic potential and the continuity equation in Maxwell’s equations is used. Also, the steady state conduction of charge is assumed. The Maxwell continuity equation is: 

\begin{equation}
\begin{aligned}
\nabla \mathbf{J} &= 0
\end{aligned}
\end{equation}

Using Ohm’s Law (J = σE) one could modify the previous equation to receive this:

\begin{equation}
\begin{aligned}
\nabla (sigma \cdot \mathbf{E}) &= 0
\end{aligned}
\end{equation}

- $J$ is the current density,
- $E$ is the electric field,
- $sigma$ is the electrical conductivity.

This is an electrostatic field given by the equation:
 
\begin{equation}
\begin{aligned}
\E &= -nabla phi
\end{aligned}
\end{equation} 
 
and substituting this into the previous expression yields: 

\begin{equation}
\begin{aligned}
\nabla \cdot (sigma nabla phi) &= 0
\end{aligned}
\end{equation} 

The potential on grounded surfaces (the bottom electrode in the cases outlined here) was set to be zero, while the RMS current value applied to the system was used to set the potential on the top boundary. This boundary condition is given by:

\begin{equation}
\begin{aligned}
\iint sigma_S nabla phi /cdot \mathbf{\hat{n}} {\text{d} S} &= I_RMS
\end{aligned}
\end{equation} 

It was assumed that the electrical conductivity of stainless steel as well as the gradient of potential changes very little radially at this boundary, away from the bulk of the heat generation occurring in the graphite assembly. In cylindrical coordinates, this allows the integrand to be placed outside the integral expression, and the integral can then be evaluated explicitly. Considering the coaxial profile of the electrodes in Figure 5.1, the integral expression becomes a differential one: 

\begin{equation}
\begin{aligned}
\sigma_S nabla phi /cdot \mathbf{\hat{n}} &= \frac{I_RMS}{pi(r_2^2 - r_1^2)}
\end{aligned}
\end{equation} 

where r1 and r2 are the inner and outer radii of the electrode geometry at the boundary. This expression was applied as a Neumann condition in the model. For outward-facing surfaces, it is assumed that they are perfect insulators. This condition is a Neumann style condition and is given by: 

\begin{equation}
\begin{aligned}
\nabla phi \mathbf{\hat{n}} &= 0
\end{aligned}
\end{equation} 

Similar to thermal contact ([ThermalContactCondition.md]), electrostatic contact between interfaces of the same material were considered perfectly continuous, such that between two identical materials A and B with current traveling across an interface in the z direction, the condition is given by:

\begin{equation}
\begin{aligned}
\frac{\partial phi}{\partial x} \bigg\rvert_A &= \frac{\partial phi}{\partial z} \bigg\rvert_B
\end{aligned}
\end{equation}

## Results and Discussion

In this section, results for each sample case will be discussed. Mesh and input files used to generate the results shown in each case can be found in the Summary section above.

### Sample One

For sample one, the die assembly shown in [sample_one] was used. Thermal and electric contact resistance was simulated on either contact surface with the stainless steel electrodes, which had the geometry shown in [sps_schematic]. The current source was turned on at t = 0, held for 20 minutes, and then turned off. The assembly was then allowed to cool back to ambient temperature (293 K) for another 40 minutes. 

!media media/electrothermal_veri_images/sample_one.pdf
    style=width:50%;margin-left:auto;margin-right:auto;
    id=sample_one
    caption=Sample one die assembly.

!media media/electrothermal_veri_images/sample_one_potential.pdf
    style=width:50%;margin-left:auto;margin-right:auto;
    id=sample_one_potential
    caption=Electric potential results shown here. 

!media media/electrothermal_veri_images/sample_one_temperature.pdf
    style=width:50%;margin-left:auto;margin-right:auto;
    id=sample_one_temperature
    caption=Temperature results displayed here. 

Cincotti compensated for any deviation in properties in the COMSOL model by using the α and β parameters in the contact conductance calculation. These parameters were experimentally derived parameters. This deviation is much less evident in later sample cases, so the parameters were left unchanged for the remainder of the validation study. It is thus important to note that tuning of the current contact model cannot be neglected when accounting for variations in material properties and model parameters with the experimental setup. Benchmarking against a system of interest should be a first step in the process of using the code implemented here.

### Sample Three

For sample three, the die assembly shown in [sample_three] was used. Thermal and electric contact resistance was simulated on either contact surface with the stainless-steel electrodes, which had the geometry shown in [sps_schematic]. The current source was turned on at t = 0, held for 20 minutes, and then turned off. The assembly was then allowed to cool back to ambient temperature (293 K) for another 40 minutes. A two-dimensional view of the sample three assembly with contact interfaces highlighted is shown in [sample_three_2d]. 

!media media/electrothermal_veri_images/sample_three.png
    style=width:50%;margin-left:auto;margin-right:auto;
    id=sample_three
    caption=Sample three die assembly.

!media media/electrothermal_veri_images/sample_three_2d.png
    style=width:50%;margin-left:auto;margin-right:auto;
    id=sample_three_2d
    caption=2D view of sample three.

Overall, results for both potential and temperature were in good agreement with the COMSOL model and decent agreement with Cincotti experimental data. Both codes had difficulty in the current model with resolving the cool-down period after the current source was turned off. 

### Sample Four

For sample four, the die assembly shown in [sample_four] was used. Thermal and electric contact resistance was simulated on either contact surface with the stainless-steel electrodes, which had the geometry shown in [sps_schematic]. The current source was turned on at t = 0, held for 10 minutes, and then turned off. The assembly was then allowed to cool back to ambient temperature (293 K) for another 20 minutes. The potential results are shown in [sample_four_potential] with the temperature results shown in [sample_four_temperature]. Considering that sample four is the more geometrically “complicated” model under examination here, there are many horizontal surfaces nearby other vertical surfaces (and vice versa). As previously seen in both conducting and non-conducting powders, heat transfer from the surrounding domain is an important part of the SPS process, and some component of that is lost in this formulation.

!media media/electrothermal_veri_images/sample_four.pdf
    style=width:50%;margin-left:auto;margin-right:auto;
    id=sample_four
    caption=Sample four die assembly.

!media media/electrothermal_veri_images/sample_four_potential.pdf
    style=width:50%;margin-left:auto;margin-right:auto;
    id=sample_four_potential
    caption=Electric potential results shown here. 

!media media/electrothermal_veri_images/sample_four_temperature.pdf
    style=width:50%;margin-left:auto;margin-right:auto;
    id=sample_four_temperature
    caption=Temperature results displayed here. 

Overall, results for both potential and temperature were in excellent agreement with the experimental data for potential. For the temperature prediction, the COMSOL and MALAMUTE models once again tracked well with each other, but both deviated within the die region (where the powder resides) and in the cool-down period. 

## Summary

### Simulation Parameters and Material Properties

The constant parameters used in this simulation corresponding to the model described earlier are shown in the table below and were gathered from [!citep](cincotti2007sps). 

!table id=constant_parameters caption=Constant parameters used in the SPS electrothermal validation cases.
| Parameter | Value | Units |
| :- | :- | :- |
| $T_0$ | 293 | K |
| f | 0.5 |  |
| h | 4725 | W m^-2 K^-1 |
| $H_G$ | 3.5 x 10^9 | Pa |
| $H_S$ | 1.92 x 10^9 | Pa |
| $eta_G$ | 0.85 |  |
| $eta_S$ | 0.4 |  |
| nu | 5.67 x 10^-8 | W m^-2 K^-4 |
| $rho_G$ | 1750 | kg m^-3 |
| $rho_S$ | 8000 | kg m^-3 |
| $alpha_T$ | 22,810 | m^-1 |
| $beta_T$ | 1.08 |  |
| $alpha_E$ | 64 | m^-1 |
| $beta_E$ | 0.35 |  |

The electrothermal material property fits used to generate the results for AISI 304 stainless steel and AT 101 graphite were generated by Pitts [here](https://inldigitallibrary.inl.gov/sites/sti/sti/Sort_26145.pdf) and are shown displayed on the material property data used to make them in functional fit graphs for stainless steel with the functions themselves in the functional fit equations. The material property data, fit quality, and applicable equations for graphite and stainless steel are shown in these MOOSE websites:

Graphite information: 

[Functional fit for AT 101 graphite specific heat capacity](https://mooseframework.inl.gov/malamute/source/materials/GraphiteThermal.html)
[Functional fit for AT 101 graphite electric resistivity](https://mooseframework.inl.gov/malamute/source/materials/GraphiteElectricalConductivity.html)
[Functional fit for AT 101 graphite thermal conductivity](https://mooseframework.inl.gov/malamute/source/materials/GraphiteThermal.html)

Stainless steel information: 

[Functional fit for AISI 304 stainless steel specific heat capacity](https://mooseframework.inl.gov/malamute/source/materials/StainlessSteelThermal.html)
[Polynomial relationship for the electrical resistivity of AISI 304 stainless steel](https://mooseframework.inl.gov/malamute/source/materials/StainlessSteelElectricalConductivity.html)
[Functional fit for AISI 304 stainless steel thermal conductivity](https://mooseframework.inl.gov/malamute/source/materials/StainlessSteelThermal.html)

A tabulated comparison of the MALAMUTE code performance with that of Cincotti’s (COMSOL) code is shown below, with data points taken just before the current source was turned off in the model.

!table id=malamute_vs_cincotti caption=MALAMUTE results comparison with Cincotti COMSOL model.
| Sample | Location | MALAMUTE (degrees Celsius) | COMSOL (degrees Celsius) | Abs. Diff (degrees Celsius) | Rel. Diff (%) |
| :- | :- | :- | :- | :- | :- |
| One | Lower Spacer | 200.76 | 175.40 | 25.36 | 14.46 |
| Three | Big Spacer | 538.97 | 540.45 | 1.48 | 0.27 |
| Three | Plunger | 927.89 | 963.28 | 35.38 | 3.67 |
| Three | Small Spacer | 678.38 | 687.34 | 8.97 | 1.31 |
| Four | Inside Die | 1158.12 | 1184.17 | 26.05 | 2.20 |
| Four | Lower Small Spacer | 890.58 | 903.07 | 12.49 | 1.38 |

As the model became more geometrically complicated, the deviations for each model relatively reduced, giving both MALAMUTE and COMSOL codes good agreement (less than 2.5% relative difference by sample four). 

This validated engineering-scale electrothermal model implemented within MOOSE can be coupled (via the MOOSE application infrastructure) to the tensor mechanics module to simulate a full-powder experiment with material thermal expansion (for example), and to help compensate for performance differences that occur during material displacements. 