/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "INSMeltPoolMassTransferMaterial.h"

registerADMooseObject("MalamuteApp", INSMeltPoolMassTransferMaterial);

InputParameters
INSMeltPoolMassTransferMaterial::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("Computes extra residuals from mass transfer for the INS equations.");
  params.addRequiredCoupledVar("temperature", "Temperature variable");
  params.addRequiredParam<Real>("atomic_weight", "Atomic weight of metal.");
  params.addRequiredParam<Real>("Boltzmann_constant", "Stefan Boltzmann constant.");
  params.addParam<Real>("retrodiffusion_coefficient", 0, "Retrodiffusion coefficient.");
  params.addRequiredParam<Real>("vaporization_latent_heat", "Latent heat of vaporization.");
  params.addRequiredParam<Real>("vaporization_temperature", "Vaporization temperature.");
  params.addRequiredParam<Real>("reference_pressure", "Reference pressure for vaporization.");
  return params;
}

INSMeltPoolMassTransferMaterial::INSMeltPoolMassTransferMaterial(const InputParameters & parameters)
  : ADMaterial(parameters),
    _temp(adCoupledValue("temperature")),
    _melt_pool_mass_rate(declareADProperty<Real>("melt_pool_mass_rate")),
    _m(getParam<Real>("atomic_weight")),
    _boltzmann(getParam<Real>("Boltzmann_constant")),
    _beta_r(getParam<Real>("retrodiffusion_coefficient")),
    _Lv(getParam<Real>("vaporization_latent_heat")),
    _vaporization_temperature(getParam<Real>("vaporization_temperature")),
    _p0(getParam<Real>("reference_pressure")),
    _saturated_vapor_pressure(declareADProperty<Real>("saturated_vapor_pressure"))
{
}

void
INSMeltPoolMassTransferMaterial::computeQpProperties()
{
  _saturated_vapor_pressure[_qp] =
      _p0 * std::exp(_m * _Lv / _boltzmann / _vaporization_temperature *
                     (1 - _vaporization_temperature / _temp[_qp]));

  _melt_pool_mass_rate[_qp] = std::sqrt(_m / (2 * libMesh::pi * _boltzmann)) *
                              _saturated_vapor_pressure[_qp] / std::sqrt(_temp[_qp]) *
                              (1 - _beta_r);
}
