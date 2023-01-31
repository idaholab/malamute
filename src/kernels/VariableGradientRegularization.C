/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "VariableGradientRegularization.h"

registerMooseObject("MalamuteApp", VariableGradientRegularization);

InputParameters
VariableGradientRegularization::validParams()
{
  InputParameters params = ADVectorKernel::validParams();
  params.addClassDescription(
      "Performs L2 projection of a variable's gradient onto a new vector variable.");
  params.addRequiredCoupledVar("regularized_var", "The variable to be regularized.");
  return params;
}

VariableGradientRegularization::VariableGradientRegularization(const InputParameters & parameters)
  : ADVectorKernel(parameters), _grad_c(adCoupledGradient("regularized_var"))
{
}

ADReal
VariableGradientRegularization::computeQpResidual()
{
  return _test[_i][_qp] * (_u[_qp] - _grad_c[_qp]);
}
