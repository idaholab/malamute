//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#ifndef PSEUDOSOLIDSTRESS_H
#define PSEUDOSOLIDSTRESS_H

#include "ADMaterial.h"

template <ComputeStage>
class PseudoSolidStress;

declareADValidParams(PseudoSolidStress);

/**
 * A material that couples a material property
 */
template <ComputeStage compute_stage>
class PseudoSolidStress : public ADMaterial<compute_stage>
{
public:
  PseudoSolidStress(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

  ADMaterialProperty(RealVectorValue) & _stress_x;
  ADMaterialProperty(RealVectorValue) & _stress_y;
  ADMaterialProperty(RealVectorValue) & _stress_z;
  const ADVariableGradient & _grad_disp_x;
  const ADVariableGradient & _grad_disp_y;
  const ADVariableGradient & _grad_disp_z;

  usingMaterialMembers;
};

#endif // PSEUDOSOLIDSTRESS_H
