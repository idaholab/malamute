/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2022, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "LevelSetPhaseChangeSUPG.h"

registerMooseObject("MalamuteApp", LevelSetPhaseChangeSUPG);

InputParameters
LevelSetPhaseChangeSUPG::validParams()
{
  InputParameters params = ADKernelGrad::validParams();
  params.addClassDescription("Computes SUPG term for interface velocity due to phase change.");
  params.addRequiredParam<Real>("rho_l", "Liquid density.");
  params.addRequiredParam<Real>("rho_g", "Gas density.");
  params.addRequiredCoupledVar("velocity", "Velocity vector variable.");
  return params;
}

LevelSetPhaseChangeSUPG::LevelSetPhaseChangeSUPG(const InputParameters & parameters)
  : ADKernelGrad(parameters),
    _delta_function(getADMaterialProperty<Real>("delta_function")),
    _heaviside_function(getADMaterialProperty<Real>("heaviside_function")),
    _melt_pool_mass_rate(getADMaterialProperty<Real>("melt_pool_mass_rate")),
    _rho_l(getParam<Real>("rho_l")),
    _rho_g(getParam<Real>("rho_g")),
    _velocity(adCoupledVectorValue("velocity"))
{
}

ADRealVectorValue
LevelSetPhaseChangeSUPG::precomputeQpResidual()
{
  ADReal tau =
      _current_elem->hmin() /
      (2 * (_velocity[_qp] + RealVectorValue(libMesh::TOLERANCE * libMesh::TOLERANCE)).norm());

  return tau * _velocity[_qp] *
         (-(_heaviside_function[_qp] / _rho_g + (1 - _heaviside_function[_qp]) / _rho_l) *
          _melt_pool_mass_rate[_qp] * _delta_function[_qp]);
}
