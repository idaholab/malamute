# Variable gradient regularization

!syntax description /Kernels/VariableGradientRegularization

## Description

The gradient of a Lagrangian shape function is discontinues. In order to get a smooth gradient field, we can perform a $L^2$ projection of the gradient onto a continues vector variable.   

## Example Input Syntax

!listing test/tests/gradient_regularization/gradient_regularization.i block=Kernels/grad_ls

!syntax parameters /Kernels/VariableGradientRegularization

!syntax inputs /Kernels/VariableGradientRegularization

!syntax children /Kernels/VariableGradientRegularization
