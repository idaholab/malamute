/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*               Copyright 2021, Battelle Energy Alliance, LLC              */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "MushyZoneMaterial.h"

registerMooseObject("MalamuteApp", MushyZoneMaterial);

InputParameters
MushyZoneMaterial::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("Computes material properties in the mushy zone.");
  params.addRequiredCoupledVar("temperature", "Temperature variable");
  params.addRequiredParam<Real>("rho_s", "Solid density.");
  params.addRequiredParam<Real>("rho_l", "Liquid density.");
  params.addRequiredParam<Real>("solidus_temperature", "Solidus temperature.");
  params.addRequiredParam<Real>("liquidus_temperature", "Liquidus temperature.");
  return params;
}

MushyZoneMaterial::MushyZoneMaterial(const InputParameters & parameters)
  : ADMaterial(parameters),
    _temp(adCoupledValue("temperature")),
    _solidus_temperature(getParam<Real>("solidus_temperature")),
    _liquidus_temperature(getParam<Real>("liquidus_temperature")),
    _f_l(declareADProperty<Real>("liquid_mass_fraction")),
    _f_s(declareADProperty<Real>("solid_mass_fraction")),
    _g_l(declareADProperty<Real>("liquid_volume_fraction")),
    _g_s(declareADProperty<Real>("solid_volume_fraction")),
    _rho_s(getParam<Real>("rho_s")),
    _rho_l(getParam<Real>("rho_l"))
{
}

void
MushyZoneMaterial::computeQpProperties()
{
  _f_l[_qp] = 1;

  if (_temp[_qp] < _solidus_temperature)
    _f_l[_qp] = 0;
  else if (_temp[_qp] >= _solidus_temperature && _temp[_qp] <= _liquidus_temperature)
    _f_l[_qp] =
        (_temp[_qp] - _solidus_temperature) / (_liquidus_temperature - _solidus_temperature);

  _f_s[_qp] = 1.0 - _f_l[_qp];

  _g_l[_qp] = _f_l[_qp] / _rho_l / ((1 - _f_l[_qp]) / _rho_s + _f_l[_qp] / _rho_l);
  _g_s[_qp] = 1.0 - _g_l[_qp];
}
