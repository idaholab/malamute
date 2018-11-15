//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "CrazyKCPlantFits.h"

registerADMooseObject("ArticunoApp", CrazyKCPlantFits);

defineADValidParams(
    CrazyKCPlantFits, ADMaterial, params.addParam<Real>("c_mu0", 0.15616, "mu0 coefficient");
    params.addParam<Real>("c_mu1", -3.3696e-5, "mu1 coefficient");
    params.addParam<Real>("c_mu2", 1.0191e-8, "mu2 coefficient");
    params.addParam<Real>("c_mu3", -1.0413e-12, "mu3 coefficient");
    params.addParam<Real>("Tmax", 4000, "The maximum temperature");
    params.addParam<Real>("Tl", 1623, "The liquidus temperature");
    params.addParam<Real>("T90",
                          1528,
                          "The T90 temperature (I don't know what this means physically)");
    params.addParam<Real>("beta", 1e11, "beta coefficient");
    params.addParam<Real>("c_k0", 10.7143, "k0 coefficient");
    params.addParam<Real>("c_k1", 14.2857e-3, "k0 coefficient");
    params.addParam<Real>("c_cp0", 425.75, "cp0 coefficient");
    params.addParam<Real>("c_cp1", 170.833e-3, "cp1 coefficient");
    params.addParam<Real>("c_rho0", 7.9e3, "The constant density");
    params.addRequiredCoupledVar("temperature", "The temperature");
    params.addParam<MaterialPropertyName>("mu_name",
                                          "mu",
                                          "The name of the viscosity material property");
    params.addParam<MaterialPropertyName>("k_name", "k", "The name of the thermal conductivity");
    params.addParam<MaterialPropertyName>("cp_name", "cp", "The name of the thermal conductivity");
    params.addParam<MaterialPropertyName>("rho_name",
                                          "rho",
                                          "The name of the thermal conductivity"););

template <ComputeStage compute_stage>
CrazyKCPlantFits<compute_stage>::CrazyKCPlantFits(const InputParameters & parameters)
  : ADMaterial<compute_stage>(parameters),
    _c_mu0(adGetParam<Real>("c_mu0")),
    _c_mu1(adGetParam<Real>("c_mu1")),
    _c_mu2(adGetParam<Real>("c_mu2")),
    _c_mu3(adGetParam<Real>("c_mu3")),
    _Tmax(adGetParam<Real>("Tmax")),
    _Tl(adGetParam<Real>("Tl")),
    _T90(adGetParam<Real>("T90")),
    _beta(adGetParam<Real>("beta")),
    _c_k0(adGetParam<Real>("c_k0")),
    _c_k1(adGetParam<Real>("c_k1")),
    _c_cp0(adGetParam<Real>("c_cp0")),
    _c_cp1(adGetParam<Real>("c_cp1")),
    _c_rho0(adGetParam<Real>("c_rho0")),
    _temperature(adCoupledValue("temperature")),
    _mu(adDeclareADProperty<Real>(adGetParam<MaterialPropertyName>("mu_name")))
// _k(adDeclareADProperty<Real>(adGetParam<MaterialPropertyName>("k_name"))),
// _cp(adDeclareADProperty<Real>(adGetParam<MaterialPropertyName>("cp_name"))),
// _rho(adDeclareADProperty<Real>(adGetParam<MaterialPropertyName>("rho_name")))
{
}

template <ComputeStage compute_stage>
void
CrazyKCPlantFits<compute_stage>::computeQpProperties()
{
  // if (_temperature[_qp] < _Tl)
  //   _mu[_qp] = (_c_mu0 + _c_mu1 * _Tl + _c_mu2 * _Tl * _Tl + _c_mu3 * _Tl * _Tl * _Tl) *
  //              (_beta + (1 - _beta) * (_temperature[_qp] - _T90) / (_Tl - _T90));
  // else
  // {
  //   typename std::remove_const<
  //       typename std::remove_reference<decltype(_temperature[_qp])>::type>::type That;
  //   That = _temperature[_qp] > _Tmax ? _Tmax : _temperature[_qp];
  //   _mu[_qp] = _c_mu0 + _c_mu1 * That + _c_mu2 * That * That + _c_mu3 * That * That * That;
  // }
  // _k[_qp] = _c_k0 + _c_k1 * _temperature[_qp];
  // _cp[_qp] = _c_cp0 + _c_cp1 * _temperature[_qp];
  // _rho[_qp] = _c_rho0;
  _mu[_qp] = _temperature[_qp];
}
