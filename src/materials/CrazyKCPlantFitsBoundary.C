//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "CrazyKCPlantFitsBoundary.h"

registerADMooseObject("ArticunoApp", CrazyKCPlantFitsBoundary);

defineADValidParams(
    CrazyKCPlantFitsBoundary,
    ADMaterial,
    params.addParam<Real>("c_mu0", 0.15616, "mu0 coefficient");
    params.addParam<Real>("ap0", 0, "");
    params.addParam<Real>("ap1", 1.851502e1, "");
    params.addParam<Real>("ap2", -1.96945e-1, "");
    params.addParam<Real>("ap3", 1.594124e-3, "");
    params.addParam<Real>("bp0", 0, "");
    params.addParam<Real>("bp1", -5.809553e1, "");
    params.addParam<Real>("bp2", 4.610515e-1, "");
    params.addParam<Real>("bp3", 2.332819e-4, "");
    params.addParam<Real>("Tb", 3000, "The boiling temperature");
    params.addParam<Real>("Tbound1", 0, "The first temperature bound");
    params.addParam<Real>("Tbound2", 170, "The second temperature bound");
    params.addCoupledVar("temperature", 1., "The temperature");
    params.addParam<MaterialPropertyName>("rc_pressure_name", "rc_pressure", "The recoil pressure");
    params.addParam<Real>("alpha",
                          -4.3e-4,
                          "The derivative of the surface tension with respect to temperature");
    params.addParam<Real>("sigma0", 1.943, "The surface tension at T0");
    params.addParam<Real>("T0", 1809, "The reference temperature for the surface tension");
    params.addParam<MaterialPropertyName>("surface_tension_name",
                                          "surface_tension",
                                          "The surface tension");
    params.addParam<MaterialPropertyName>("grad_surface_tension_name",
                                          "grad_surface_tension",
                                          "The gradient of the surface tension"););

template <ComputeStage compute_stage>
CrazyKCPlantFitsBoundary<compute_stage>::CrazyKCPlantFitsBoundary(
    const InputParameters & parameters)
  : ADMaterial<compute_stage>(parameters),
    _ap0(adGetParam<Real>("ap0")),
    _ap1(adGetParam<Real>("ap1")),
    _ap2(adGetParam<Real>("ap2")),
    _ap3(adGetParam<Real>("ap3")),
    _bp0(adGetParam<Real>("bp0")),
    _bp1(adGetParam<Real>("bp1")),
    _bp2(adGetParam<Real>("bp2")),
    _bp3(adGetParam<Real>("bp3")),
    _Tb(adGetParam<Real>("Tb")),
    _Tbound1(adGetParam<Real>("Tbound1")),
    _Tbound2(adGetParam<Real>("Tbound2")),
    _temperature(adCoupledValue("temperature")),
    _grad_temperature(adCoupledGradient("temperature")),
    _rc_pressure(adDeclareADProperty<Real>(adGetParam<MaterialPropertyName>("rc_pressure_name"))),
    _alpha(adGetParam<Real>("alpha")),
    _sigma0(adGetParam<Real>("sigma0")),
    _T0(adGetParam<Real>("T0")),
    _surface_tension(
        adDeclareADProperty<Real>(adGetParam<MaterialPropertyName>("surface_tension_name"))),
    _grad_surface_tension(adDeclareADProperty<RealVectorValue>(
        adGetParam<MaterialPropertyName>("grad_surface_tension_name")))
{
}

template <ComputeStage compute_stage>
void
CrazyKCPlantFitsBoundary<compute_stage>::computeQpProperties()
{
  auto && theta = _temperature[_qp] - _Tb;
  if (theta < _Tbound1)
    _rc_pressure[_qp] = 0;
  else if (theta < _Tbound2)
    _rc_pressure[_qp] = _ap0 + _ap1 * theta + _ap2 * theta * theta + _ap3 * theta * theta * theta;
  else
    _rc_pressure[_qp] = _bp0 + _bp1 * theta + _bp2 * theta * theta + _bp3 * theta * theta * theta;

  _surface_tension[_qp] = _sigma0 + _alpha * (_temperature[_qp] - _T0);
  _grad_surface_tension[_qp] = _alpha * _grad_temperature[_qp];
}
