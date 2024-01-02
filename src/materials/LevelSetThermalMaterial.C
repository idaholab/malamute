/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "LevelSetThermalMaterial.h"

registerMooseObject("MalamuteApp", LevelSetThermalMaterial);

InputParameters
LevelSetThermalMaterial::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("Computes thermal properties in melt pool heat equations");
  params.addRequiredCoupledVar("temperature", "Temperature variable");
  params.addRequiredParam<Real>("c_g", "Gas specific heat.");
  params.addRequiredParam<Real>("c_s", "Solid specific heat.");
  params.addRequiredParam<Real>("c_l", "Liquid specific heat.");
  params.addRequiredParam<Real>("k_g", "Gas heat conductivity.");
  params.addRequiredParam<Real>("k_s", "Solid conductivity.");
  params.addRequiredParam<Real>("k_l", "Liquid conductivity.");
  params.addRequiredParam<Real>("solidus_temperature", "Solidus temperature.");
  params.addRequiredParam<Real>("latent_heat", "Latent heat.");
  return params;
}

LevelSetThermalMaterial::LevelSetThermalMaterial(const InputParameters & parameters)
  : ADMaterial(parameters),
    _temp(adCoupledValue("temperature")),
    _heaviside_function(getADMaterialProperty<Real>("heaviside_function")),
    _h(declareADProperty<Real>("enthalpy")),
    _k(declareADProperty<Real>("thermal_conductivity")),
    _cp(declareADProperty<Real>("specific_heat")),
    _c_g(getParam<Real>("c_g")),
    _c_s(getParam<Real>("c_s")),
    _c_l(getParam<Real>("c_l")),
    _k_g(getParam<Real>("k_g")),
    _k_s(getParam<Real>("k_s")),
    _k_l(getParam<Real>("k_l")),
    _latent_heat(getParam<Real>("latent_heat")),
    _solidus_temperature(getParam<Real>("solidus_temperature")),
    _f_l(getADMaterialProperty<Real>("liquid_mass_fraction")),
    _f_s(getADMaterialProperty<Real>("solid_mass_fraction")),
    _g_l(getADMaterialProperty<Real>("liquid_volume_fraction")),
    _g_s(getADMaterialProperty<Real>("solid_volume_fraction"))
{
}

void
LevelSetThermalMaterial::computeQpProperties()
{
  ADReal delta_l = (_c_s - _c_l) * _solidus_temperature + _latent_heat;

  ADReal f_l = _f_l[_qp] * (1 - _heaviside_function[_qp]);
  ADReal f_s = _f_s[_qp] * (1 - _heaviside_function[_qp]);
  ADReal c_m = (f_s * _c_s + f_l * _c_l) * (1 - _heaviside_function[_qp]);
  ADReal k_m = 1.0 / (_g_s[_qp] / _k_s + _g_l[_qp] / _k_l);
  ADReal h_m = c_m * _temp[_qp] + f_l * (1 - _heaviside_function[_qp]) * delta_l;
  ADReal h_g = _c_g * _temp[_qp];

  _h[_qp] = (1 - _heaviside_function[_qp]) * h_m + _heaviside_function[_qp] * h_g;
  _k[_qp] = (1 - _heaviside_function[_qp]) * k_m + _heaviside_function[_qp] * _k_g;
  _cp[_qp] = (1 - _heaviside_function[_qp]) * c_m + _heaviside_function[_qp] * _c_g;
}
