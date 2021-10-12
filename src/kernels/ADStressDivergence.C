//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ADStressDivergence.h"

registerMooseObject("LaserWeldingApp", ADStressDivergence);

InputParameters
ADStressDivergence::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addRequiredParam<int>("component", "The displacement component");
  return params;
}

ADStressDivergence::ADStressDivergence(const InputParameters & parameters) : ADKernel(parameters)
{
  const auto component = getParam<int>("component");
  if (component == 0)
    _stress = &getADMaterialProperty<RealVectorValue>("stress_x");
  else if (component == 1)
    _stress = &getADMaterialProperty<RealVectorValue>("stress_y");
  else if (component == 2)
    _stress = &getADMaterialProperty<RealVectorValue>("stress_z");
  else
    mooseError("component must be either 0, 1, or 2");
}

ADReal
ADStressDivergence::computeQpResidual()
{
  return _grad_test[_i][_qp] * (*_stress)[_qp];
}
