/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "LevelSetGradientRegularizationReinitialization.h"

registerMooseObject("MalamuteApp", LevelSetGradientRegularizationReinitialization);

InputParameters
LevelSetGradientRegularizationReinitialization::validParams()
{
  InputParameters params = ADKernelGrad::validParams();
  params.addClassDescription("The re-initialization equation that uses regularized gradient.");
  params.addRequiredCoupledVar("level_set_gradient",
                               "Regularized gradient of the level set variable");
  params.addRequiredParam<Real>(
      "epsilon", "The epsilon coefficient to be used in the reinitialization calculation.");
  return params;
}

LevelSetGradientRegularizationReinitialization::LevelSetGradientRegularizationReinitialization(
    const InputParameters & parameters)
  : ADKernelGrad(parameters),
    _grad_c(coupledVectorValue("level_set_gradient")),
    _epsilon(getParam<Real>("epsilon"))
{
}

ADRealVectorValue
LevelSetGradientRegularizationReinitialization::precomputeQpResidual()
{
  Real s = (_grad_c[_qp] + RealVectorValue(libMesh::TOLERANCE)).norm();
  RealVectorValue n_hat = _grad_c[_qp] / s;
  ADRealVectorValue f = _u[_qp] * (1 - _u[_qp]) * n_hat;

  return (-f + _epsilon * _grad_u[_qp]);
}
