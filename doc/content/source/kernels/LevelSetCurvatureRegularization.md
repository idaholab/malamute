# Level set curvature regularization

!syntax description /Kernels/LevelSetCurvatureRegularization

## Description

An approximation of the regularized curvature [!citep](OLSSON2007) is: Find $\kappa \in V_h$ such that
\begin{equation}
\int_{\Omega}v\kappa~\text{d}x = \int_{\Omega}\nabla v \cdot \frac{\nabla c}{|\nabla c|}~\text{d}x - \epsilon\int_{\Omega}\nabla v\cdot \nabla\kappa~\text{d}x~~~\forall v\in V_h,
\end{equation}
where $\nabla c$ is the regularized gradient [VariableGradientRegularization.md] of a level set variable and $\epsilon$ is regularization parameter.

## Example Input Syntax

!listing test/tests/curvature_regularization/curvature_regularization.i block=Kernels/curvature

!syntax parameters /Kernels/LevelSetCurvatureRegularization

!syntax inputs /Kernels/LevelSetCurvatureRegularization

!syntax children /Kernels/LevelSetCurvatureRegularization
