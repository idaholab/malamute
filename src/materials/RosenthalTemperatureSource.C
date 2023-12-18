/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "RosenthalTemperatureSource.h"

registerMooseObject("MalamuteApp", RosenthalTemperatureSource);
registerMooseObject("MalamuteApp", ADRosenthalTemperatureSource);

template <bool is_ad>
InputParameters
RosenthalTemperatureSourceTempl<is_ad>::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("Computes the thermal profile following the Rosenthal equation");
  params.addParam<MaterialPropertyName>(
      "thermal_conductivity", "thermal_conductivity", "Property name of the thermal conductivity");
  params.addParam<MaterialPropertyName>(
      "specific_heat", "specific_heat", "Property name of the specific heat");
  params.addParam<MaterialPropertyName>("density", "density", "Property name of the density");
  params.addParam<MaterialPropertyName>(
      "absorptivity", "absorptivity", "Property name of the power absorption coefficient");
  params.addRequiredParam<Real>("power", "Laser power");
  params.addRequiredParam<Real>("velocity", "Scanning velocity");
  params.addParam<Real>(
      "ambient_temperature", 300, "Ambient temparature far away from the surface");
  params.addRequiredParam<Real>("melting_temperature", "Melting temparature of the material");
  params.addParam<Real>("initial_position", 0.0, "Initial coordiate of the heat source");
  return params;
}
template <bool is_ad>
RosenthalTemperatureSourceTempl<is_ad>::RosenthalTemperatureSourceTempl(
    const InputParameters & parameters)
  : Material(parameters),
    _P(getParam<Real>("power")),
    _V(getParam<Real>("velocity")),
    _T0(getParam<Real>("ambient_temperature")),
    _Tm(getParam<Real>("melting_temperature")),
    _x0(getParam<Real>("initial_position")),
    _thermal_conductivity(getGenericMaterialProperty<Real, is_ad>("thermal_conductivity")),
    _specific_heat(getGenericMaterialProperty<Real, is_ad>("specific_heat")),
    _density(getGenericMaterialProperty<Real, is_ad>("density")),
    _absorptivity(getGenericMaterialProperty<Real, is_ad>("absorptivity")),
    _thermal_diffusivity(declareGenericProperty<Real, is_ad>("thermal_diffusivity")),
    _temp_source(declareGenericProperty<Real, is_ad>("temp_source")),
    _meltpool_depth(declareGenericProperty<Real, is_ad>("meltpool_depth")),
    _meltpool_width(declareGenericProperty<Real, is_ad>("meltpool_width"))
{
}

template <bool is_ad>
void
RosenthalTemperatureSourceTempl<is_ad>::computeQpProperties()
{
  const Real & x = _q_point[_qp](0);
  const Real & y = _q_point[_qp](1);
  const Real & z = _q_point[_qp](2);

  // Moving heat source and distance
  Real x_t = x - _x0 - _V * _t;
  Real r = std::sqrt(x_t * x_t + y * y + z * z);

  _thermal_diffusivity[_qp] = _thermal_conductivity[_qp] / (_specific_heat[_qp] * _density[_qp]);

  _temp_source[_qp] = _T0 + (_absorptivity[_qp] * _P) /
                                (2.0 * libMesh::pi * _thermal_conductivity[_qp] * r) *
                                std::exp(-_V / (2.0 * _thermal_diffusivity[_qp]) * (r + x_t));
  if (_temp_source[_qp] > _Tm)
    _temp_source[_qp] = _Tm;

  _meltpool_depth[_qp] =
      std::sqrt((2.0 * _absorptivity[_qp] * _P) / (std::exp(1.0) * libMesh::pi * _density[_qp] *
                                                   _specific_heat[_qp] * (_Tm - _T0) * _V));

  _meltpool_width[_qp] = 2.0 * _meltpool_depth[_qp];
}

template class RosenthalTemperatureSourceTempl<false>;
template class RosenthalTemperatureSourceTempl<true>;
