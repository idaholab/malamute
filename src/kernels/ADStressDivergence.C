/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "ADStressDivergence.h"

registerMooseObject("MalamuteApp", ADStressDivergence);

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
