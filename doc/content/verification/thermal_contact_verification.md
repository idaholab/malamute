# Thermal Contact Condition Verification Case

This document describes the two block 1-D verification test for the
[ThermalContactCondition.md] object. Below is a summary of the test, along with
a derivation of the analytic solution used for comparison and the relevant test
input file for review.

## Summary

!style halign=left
A visual summary of the two block verification test domain, as well as relevant
boundary and interface conditions is shown below (click to zoom):

!media media/thermal_contact/thermal_two_block.png
       style=width:100%;
       id=thermal-two-block-summary
       caption=Visual summary of the two block verification test with boundary and interface conditions.

It is important to note that in [thermal-two-block-summary]:

- $k_{i}$ is the thermal conductivity of material $i$,
- $C_E$ is the electrical contact conductance at the interface,
- $C_T$ is the thermal contact conductance at the interface,
- $\phi_i$ is the electrostatic potential of material $i$, and
- $T_i$ is the temperature of material $i$.

See the [ThermalContactCondition.md] documentation for more information about
the particular definition of $C_T$ and $C_E$. In order to simplify for the
analytic solution derivation, the scenario was assumed to be steady state in
order to remove the time derivative term of the heat conduction equation. The
heating source term is electrothermal (or Joule) heating. This leads to

!equation id=steady-heat-conduction
-\nabla(k_i \nabla T_i) = \sigma_{el, i} \left( \nabla \phi_i \right)^2

where $\sigma_{el, i}$ is the electrical conductivity of material $i$. Material
properties being used in this case are constants within each block, and they are
summarized below in [thermal-two-block-mat-props]. All material properties were
evaluated at a temperature of ~300 K.

!table id=thermal-two-block-mat-props caption=Material properties for the two block thermal contact verification case.
| Property (unit) | Value | Source |
| - | - | - |
| Stainless Steel (304) Electrical Conductivity (S / m) | $1.41867 \times 10^6$ | [!citep](cincotti2007sps) |
| Stainless Steel (304) Thermal Conductivity (W / (m K)) | $15$ | [!citep](cincotti2007sps) |
| Stainless Steel (304) Hardness  (Pa) | $1.92 \times 10^9$ | [!citep](cincotti2007sps) |
| Graphite (AT 101) Electrical Conductivity (S / m) | $73069.2$ | [!citep](cincotti2007sps) |
| Graphite (AT 101) Thermal Conductivity (W / (m K)) | $100$ | [!citep](cincotti2007sps) |
| Graphite (AT 101) Hardness (Pa) | $3.5 \times 10^9$ | [!citep](cincotti2007sps) |

The hardness values shown in [thermal-two-block-mat-props] are used in the
[ThermalContactCondition.md] object as a harmonic mean of the two values.
For reference, the harmonic mean calculation for two values, $V_a$ and $V_b$, is
given by

!equation
V_{Harm} = \frac{2 V_a V_b}{V_a + V_b}

The harmonic mean of hardness for stainless steel and graphite was calculated and
set to be $2.4797 \times 10^9$ Pa. Harmonic mean values for the conductivities of
stainless steel and graphite were also calculated in this way. Applied mechanical
pressure was set to be $3000$ $kN/m^2$. The mean hardness, mean conductivities,
and applied mechanical pressure are all used to determine $C_E$ and $C_T$ (see
the [ThermalContactCondition.md] documentation, [!citep](cincotti2007sps), and
[!citep](madhusadana1996) for more information). The resulting calculated
contact conductances were hard-coded in the input file shown near the bottom
of this page, and are summarized below in [input-conductance-values].

!table id=input-conductance-values caption=Thermal and electrical conductance values used in the thermal contact verification input file.
| Conductance (units) | Value |
| - | - |
| $C_E$ ($\Omega^{-1} m^{-2}$) | 75524.0 |
| $C_T$ ($W m^{-2} K^{-1}$) | 0.242 |

### Potential Function

!style halign=left
The electrostatic potential function used in this test was determined based on
the following scenario

!media large_media/electromagnetics/two_block.png
       style=width:100%;
       id=two-block-summary
       caption=Visual summary of the two block electrostatic verification test with boundary and interface conditions.

where the interface condition above is the [ElectrostaticContactCondition.md]. Solving for $\phi_i$ in each domain (using the same material properties and
parameters outlined for this verification test) results in

\begin{equation}
\begin{aligned}
\phi_S (x) &= \frac{-C_E \sigma_G}{\sigma_G \sigma_S + C_E \sigma_G + C_E \sigma_S} x + 1 \\
\phi_G (x) &= \frac{-C_E \sigma_S}{\sigma_G \sigma_S + C_E \sigma_G + C_E \sigma_S} (x - 2)
\end{aligned}
\end{equation}

This result was implemented in source code in both `ThermalContactTemperatureTestFunc`
(for use in the final analytic result presented below) and in
`ThermalContactPotentialTestFunc` (for use in the input file as the value of
an auxiliary coupled variable). Both of these can be found in `freya/test/src`.

## Analytic Solution Derivation

!style halign=left
In 1-D, [!eqref](steady-heat-conduction) becomes

!equation id=derivation-differential-equation
-k_i \frac{\text{d}^2 T_i}{\text{d} x^2} = \sigma_{el, i} \left( \frac{\text{d} \phi_i}{\text{d} x} \right)^2

since $k_i$ is constant in both domains. Given that the gradient of the potential
function used in this example is a linear one (so the right-hand-side is constant),
this equation suggests a reasonable guess for a generic solution function for $T_i$
would be

!equation id=general-form
T_i (x) = A_i x^2 + B_i x + D_i

where $A_i$, $B_i$, and $D_i$ are to-be-determined constant coefficients.

### Apply differential equation

!style halign=left
Using [!eqref](derivation-differential-equation) and [!eqref](general-form), we can determine $A$ for both
the stainless steel and graphite domains:

!row!
!col! small=12 medium=6 large=6
!style halign=center
+Stainless Steel+

\begin{equation}
\begin{aligned}
\frac{\text{d}^2 T_S}{\text{d} x^2} &= 2 A_S \\
-k_S \frac{\text{d}^2 T_S}{\text{d} x^2} &= -2 k_S A_S \\
-2 k_S A_S &= \sigma_{el, S} \left( \frac{\text{d} \phi_S}{\text{d} x} \right)^2 \\
A_S &= -\frac{\sigma_{el, S}}{2 k_S} \left( \frac{\text{d} \phi_S}{\text{d} x} \right)^2
\end{aligned}
\end{equation}

!col-end!

!col! small=12 medium=6 large=6

!style halign=center
+Graphite+

\begin{equation}
\begin{aligned}
\frac{\text{d}^2 T_G}{\text{d} x^2} &= 2 A_G \\
-k_G \frac{\text{d}^2 T_G}{\text{d} x^2} &= -2 k_G A_G \\
-2 k_G A_G &= \sigma_{el, G} \left( \frac{\text{d} \phi_G}{\text{d} x} \right)^2 \\
A_G &= -\frac{\sigma_{el, G}}{2 k_G} \left( \frac{\text{d} \phi_G}{\text{d} x} \right)^2
\end{aligned}
\end{equation}

!col-end!
!row-end!

### Apply boundary conditions

!style halign=left
Applying the boundary conditions, we can determine $D$ for both the stainless
steel and graphite domains (with the caveat that we still need to do a bit more
work for $D_G$):

!row!
!col! small=12 medium=6 large=6
!style halign=center
+Stainless Steel+

\begin{equation}
\begin{aligned}
T_S (0) &= A_S (0)^2 + B_S (0) + D_S \\
T_S (0) &= D_S \\
D_S &= 300
\end{aligned}
\end{equation}

!col-end!

!col! small=12 medium=6 large=6

!style halign=center
+Graphite+

\begin{equation}
\begin{aligned}
T_G (2) &= A_G (2)^2 + B_G (2) + D_G \\
T_G (2) &= 4 A_G + 2 B_G + D_G \\
D_G &= T_G (2) - 4 A_G - 2 B_G \\
D_G &= 300 - 4 A_G - 2 B_G
\end{aligned}
\end{equation}

!col-end!
!row-end!

### Apply interface conditions

!style halign=left
Now, the interface conditions can be applied from [thermal-two-block-summary].
To begin, let's focus on the heat flux condition on the stainless steel side of
the interface at $x = 1$.

!equation
-k_S \left. \frac{\text{d} T_S}{\text{d} x} \right|_{x = 1} = q_c - q_e

Given that $q_c = C_T \left( T_S (1) - T_G (1) \right)$ and $T_i$ has the form
in [!eqref](general-form), we have

\begin{equation}
\begin{aligned}
-k_S \left. \frac{\text{d} T_S}{\text{d} x} \right|_{x = 1} &= C_T \left( T_S (1) - T_G (1) \right) - q_e \\
&= C_T \left( A_S (1)^2 + B_S (1) + 300 - \left[ A_G (1)^2 + B_G (1) + 300 - 4 A_G - 2 B_G \right] \right) - q_e \\
-k_S \left( 2 A_S (1) + B_S \right) &= C_T \left( A_S + B_S + 300 - A_G - B_G - 300 + 4 A_G + 2 B_G \right) - q_e \\
-2 k_S A_S - k_S B_S &= C_T \left( A_S + B_S + 3 A_G + B_G \right) - q_e \\
-2 k_S A_S - k_S B_S &= C_T A_S + C_T B_S + 3 C_T A_G + C_T B_G - q_e \\
-(k_S + C_T) B_S - C_T B_G &= 2 k_S A_S + C_T A_S + 3 C_T A_G - q_e
\end{aligned}
\end{equation}

If we let $J_S = 2 k_S A_S + C_T A_S + 3 C_T A_G - q_e$, then we have

!equation id=condition-one
-(k_S + C_T) B_S - C_T B_G = J_S

Next, we can apply the heat flux condition on the graphite side of the interface
at $x = 1$.

!equation
-k_G \left. \frac{\text{d} T_G}{\text{d} x} \right|_{x = 1} = q_c + q_e

Again, given $q_c$ and [!eqref](general-form), we have

\begin{equation}
\begin{aligned}
-k_G \left. \frac{\text{d} T_G}{\text{d} x} \right|_{x = 1} &= C_T \left( T_S (1) - T_G (1) \right) + q_e \\
&= C_T \left( A_S (1)^2 + B_S (1) + 300 - \left[ A_G (1)^2 + B_G (1) + 300 - 4 A_G - 2 B_G \right] \right) + q_e \\
-k_G \left( 2 A_G (1) + B_G \right) &= C_T \left( A_S + B_S + 300 - A_G - B_G - 300 + 4 A_G + 2 B_G \right) + q_e \\
-2 k_G A_G - k_G B_G &= C_T \left( A_S + B_S + 3 A_G + B_G \right) + q_e \\
-2 k_G A_G - k_G B_G &= C_T A_S + C_T B_S + 3 C_T A_G + C_T B_G + q_e \\
-C_T B_S - (k_G + C_T) B_G &= 2 k_G A_G + C_T A_S + 3 C_T A_G + q_e
\end{aligned}
\end{equation}

If we let $J_G = 2 k_G A_G + C_T A_S + 3 C_T A_G + q_e$, then we have

!equation id=condition-two
-C_T B_S - (k_G + C_T) B_G = J_G

### Find the remaining coefficients

!style halign=left
Using the Elimination Method, we can combine [!eqref](condition-one) and
[!eqref](condition-two) in order to solve for each remaining unknown coefficient.
If [!eqref](condition-one) is multiplied through on both sides by $C_T$ and
[!eqref](condition-two) is multiplied through on both sides by $-(k_S + C_T)$,
we have

!equation id=condition-one-a
-C_T (k_S + C_T) B_S - C_T^2 B_G = C_T J_S

and

!equation id=condition-two-a
C_T (k_S + C_T) B_S + (k_S + C_T) (k_G + C_T) B_G = -(k_S + C_T) J_G

Combining [!eqref](condition-one-a) and [!eqref](condition-two-a) together via
addition yields

\begin{equation}
\begin{aligned}
C_T (k_S + C_T) B_S + (k_S + C_T) (k_G + C_T) B_G - C_T (k_S + C_T) B_S - C_T^2 B_G &= C_T J_S - (k_S + C_T) J_G \\
(k_S + C_T) (k_G + C_T) B_G - C_T^2 B_G &= C_T J_S - (k_S + C_T) J_G \\
((k_S + C_T) (k_G + C_T) - C_T^2) B_G &= C_T J_S - (k_S + C_T) J_G \\
\end{aligned}
\end{equation}

which can then be solved for $B_G$

!equation
B_G = \frac{C_T J_S - (k_S + C_T) J_G}{(k_S + C_T) (k_G + C_T) - C_T^2}

Using [!eqref](condition-two) and $B_G$, we can now solve for $B_S$:

\begin{equation}
\begin{aligned}
-C_T B_S - (k_G + C_T) \frac{C_T J_S - (k_S + C_T) J_G}{(k_S + C_T) (k_G + C_T) - C_T^2} &= J_G \\
-C_T B_S  &= J_G + (k_G + C_T) \frac{C_T J_S - (k_S + C_T) J_G}{(k_S + C_T) (k_G + C_T) - C_T^2} \\
-C_T B_S  &= \frac{(k_S + C_T) (k_G + C_T) J_G - C_T^2 J_G}{(k_S + C_T) (k_G + C_T) - C_T^2} + \frac{C_T (k_G + C_T) J_S - (k_S + C_T) (k_G + C_T) J_G}{(k_S + C_T) (k_G + C_T) - C_T^2} \\
-C_T B_S  &= \frac{(k_S + C_T) (k_G + C_T) J_G - C_T^2 J_G + C_T (k_G + C_T) J_S - (k_S + C_T) (k_G + C_T) J_G}{(k_S + C_T) (k_G + C_T) - C_T^2} \\
-C_T B_S  &= \frac{-C_T^2 J_G + C_T (k_G + C_T) J_S}{(k_S + C_T) (k_G + C_T) - C_T^2} \\
B_S  &= \frac{C_T J_G - (k_G + C_T) J_S}{(k_S + C_T) (k_G + C_T) - C_T^2} \\
\end{aligned}
\end{equation}

### Summarize

!style halign=left
Now our determined coefficients can be combined to form the complete solutions
for both stainless steel and graphite. To summarize, the derived analytical
solutions for each domain given the boundary and interface conditions described
in [thermal-two-block-summary] is

\begin{equation}
\begin{aligned}
T_S (x) &= -\frac{\sigma_{el, S}}{2 k_S} \left( \frac{\text{d} \phi_S}{\text{d} x} \right)^2 x^2 + \frac{C_T J_G - (k_G + C_T) J_S}{(k_S + C_T) (k_G + C_T) - C_T^2} x + 300 \\
T_G (x) &= -\frac{\sigma_{el, G}}{2 k_G} \left( \frac{\text{d} \phi_G}{\text{d} x} \right)^2 (x^2 - 4) + \frac{C_T J_S - (k_S + C_T) J_G}{(k_S + C_T) (k_G + C_T) - C_T^2} (x - 2) + 300
\end{aligned}
\end{equation}

where

\begin{equation}
\begin{aligned}
J_S &= -(2 k_S + C_T) \frac{\sigma_{el, S}}{2 k_S} \left( \frac{\text{d} \phi_S}{\text{d} x} \right)^2 - 3 C_T \frac{\sigma_{el, G}}{2 k_G} \left( \frac{\text{d} \phi_G}{\text{d} x} \right)^2 - q_e \\
J_G &= -(2 k_G  + 3 C_T) \frac{\sigma_{el, G}}{2 k_G} \left( \frac{\text{d} \phi_G}{\text{d} x} \right)^2 - C_T \frac{\sigma_{el, S}}{2 k_S} \left( \frac{\text{d} \phi_S}{\text{d} x} \right)^2 + q_e \\
q_e &= \frac{C_E}{2} \left( \phi_S (1) - \phi_G(1) \right)^2
\end{aligned}
\end{equation}

This is implemented in source code as `ThermalContactTemperatureTestFunc`. It
can be found in the test source code directory located at `freya/test/src`.

## Input File

!listing thermal_interface_analytic_solution_two_block.i

## Results

!style halign=left
Results from the input file shown above compared to the analytic function are
shown below in [thermal-two-block-results]. Note that the number of points shown
in the plot has been down-sampled compared to the solved number of elements for
readability.

!media media/thermal_contact/thermal_two_block_results.png
       style=width:50%;margin:auto;
       id=thermal-two-block-results
       caption=Results of electrothermal contact two block validation case.
