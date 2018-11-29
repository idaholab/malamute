//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#ifndef CRAZYKCPLANTFITSBOUNDARY_H_
#define CRAZYKCPLANTFITSBOUNDARY_H_

#include "ADMaterial.h"

template <ComputeStage>
class CrazyKCPlantFitsBoundary;

declareADValidParams(CrazyKCPlantFitsBoundary);

/**
 * A material that couples a material property
 */
template <ComputeStage compute_stage>
class CrazyKCPlantFitsBoundary : public ADMaterial<compute_stage>
{
public:
  CrazyKCPlantFitsBoundary(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

  const Real _ap0;
  const Real _ap1;
  const Real _ap2;
  const Real _ap3;
  const Real _bp0;
  const Real _bp1;
  const Real _bp2;
  const Real _bp3;
  const Real _Tb;
  const Real _Tbound1;
  const Real _Tbound2;

  const ADVariableValue & _temperature;

  ADMaterialProperty(Real) & _rc_pressure;

  usingMaterialMembers;
};

#endif // CRAZYKCPLANTFITSBOUNDARY_H
