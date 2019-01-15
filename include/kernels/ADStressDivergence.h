//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#ifndef ADSTRESSDIVERGENCE_H
#define ADSTRESSDIVERGENCE_H

#include "ADKernel.h"
#include "MaterialProperty.h"

// Forward Declaration
template <ComputeStage compute_stage>
class ADStressDivergence;

declareADValidParams(ADStressDivergence);

template <ComputeStage compute_stage>
class ADStressDivergence : public ADKernel<compute_stage>
{
public:
  ADStressDivergence(const InputParameters & parameters);

protected:
  virtual ADResidual computeQpResidual();

  ADMaterialProperty(RealVectorValue) const * _stress;

  usingKernelMembers;
};

#endif // ADSTRESSDIVERGENCE_H
