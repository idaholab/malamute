//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "ADStressDivergence.h"

registerADMooseObject("LaserWeldingApp", ADStressDivergence);

defineADValidParams(ADStressDivergence,
                    ADKernel,
                    params.addRequiredParam<int>("component", "The displacement component"););

template <ComputeStage compute_stage>
ADStressDivergence<compute_stage>::ADStressDivergence(const InputParameters & parameters)
  : ADKernel<compute_stage>(parameters)
{
  const auto component = adGetParam<int>("component");
  if (component == 0)
    _stress = &adGetADMaterialProperty<RealVectorValue>("stress_x");
  else if (component == 1)
    _stress = &adGetADMaterialProperty<RealVectorValue>("stress_y");
  else if (component == 2)
    _stress = &adGetADMaterialProperty<RealVectorValue>("stress_z");
  else
    mooseError("component must be either 0, 1, or 2");
}

template <ComputeStage compute_stage>
ADResidual
ADStressDivergence<compute_stage>::computeQpResidual()
{
  return _grad_test[_i][_qp] * (*_stress)[_qp];
}
