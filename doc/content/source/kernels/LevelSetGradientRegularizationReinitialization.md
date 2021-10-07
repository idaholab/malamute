# LevelSetGradientRegularizationReinitialization

!syntax description /Kernels/LevelSetGradientRegularizationReinitialization

## Description

This kernel implements the conservative "re-initialization" algorithm
of [!cite](olsson2007conservative) where the regularized gradient of level set variable is used.

## Example Syntax

!listing test/tests/melt_pool_level_set/reinit.i block=Kernels/reinit

!syntax parameters /Kernels/LevelSetGradientRegularizationReinitialization

!syntax inputs /Kernels/LevelSetGradientRegularizationReinitialization

!syntax children /Kernels/LevelSetGradientRegularizationReinitialization
