# Level set Delta function

!syntax description /Materials/LevelSetDeltaFunction

## Description

For the level set defined by [!cite](OLSSON2005), the delta function (derivative of Heaviside function) is the norm of level set gradient, i.e. $|\nabla c|$.  

## Example Input Syntax

!listing test/tests/melt_pool_heat/thermal_material.i block=Materials/delta

!syntax parameters /Materials/LevelSetDeltaFunction

!syntax inputs /Materials/LevelSetDeltaFunction

!syntax children /Materials/LevelSetDeltaFunction
