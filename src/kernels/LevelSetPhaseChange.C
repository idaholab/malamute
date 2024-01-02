/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "LevelSetPhaseChange.h"

registerMooseObject("MalamuteApp", LevelSetPhaseChange);

InputParameters
LevelSetPhaseChange::validParams()
{
  InputParameters params = ADKernelValue::validParams();
  params.addClassDescription("Computes interface velocity due to phase change.");
  params.addRequiredParam<Real>("rho_l", "Liquid density.");
  params.addRequiredParam<Real>("rho_g", "Gas density.");
  return params;
}

LevelSetPhaseChange::LevelSetPhaseChange(const InputParameters & parameters)
  : ADKernelValue(parameters),
    _delta_function(getADMaterialProperty<Real>("delta_function")),
    _heaviside_function(getADMaterialProperty<Real>("heaviside_function")),
    _melt_pool_mass_rate(getADMaterialProperty<Real>("melt_pool_mass_rate")),
    _rho_l(getParam<Real>("rho_l")),
    _rho_g(getParam<Real>("rho_g"))
{
}

ADReal
LevelSetPhaseChange::precomputeQpResidual()
{
  return -(_heaviside_function[_qp] / _rho_g + (1 - _heaviside_function[_qp]) / _rho_l) *
         _melt_pool_mass_rate[_qp] * _delta_function[_qp];
}
