# GraphiteStainlessMeanHardness

!syntax description /Materials/GraphiteStainlessMeanHardness

## Description

This material object calculates the harmonic mean of the hardness values for
AT 101 graphite and AISI 304 stainless steel. The defined constant hardness
values are taken from [!citep](cincotti2007sps), and are as follows:

| Parameter | Value (Pa) |
| :- | :- |
| $H_G$ | $3.5 \times 10^9$ |
| $H_{SS}$ | $1.92 \times 10^9$ |

The harmonic mean of these hardness values can be calculated as

\begin{equation}
  H_{Harm} = \frac{2 H_G H_{SS}}{H_G + H_{SS}}
\end{equation}

which leads to a value of approximately $2.4797 \times 10^9$ Pa.

## Example Input File Syntax

!listing test/tests/materials/hardness/mean_hardness.i block=Materials


!syntax parameters /Materials/GraphiteStainlessMeanHardness

!syntax inputs /Materials/GraphiteStainlessMeanHardness

!syntax children /Materials/GraphiteStainlessMeanHardness
