/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "INSMeltPoolMaterial.h"

registerADMooseObject("MalamuteApp", INSMeltPoolMaterial);

InputParameters
INSMeltPoolMaterial::validParams()
{
  InputParameters params = INSADStabilized3Eqn::validParams();
  params.addClassDescription("Computes extra residuals from melt pool for the INS equations.");
  params.addRequiredCoupledVar("level_set_gradient", "Regularized gradient of Level set variable");
  params.addRequiredCoupledVar("curvature", "Regularized curvature variable");
  params.addRequiredParam<Real>("surface_tension", "Surface tension coefficient.");
  params.addRequiredParam<Real>("thermal_capillary", "Thermalcapillary coefficient.");
  params.addRequiredParam<Real>("rho_l", "Liquid density.");
  params.addRequiredParam<Real>("rho_g", "Gas density.");
  return params;
}

INSMeltPoolMaterial::INSMeltPoolMaterial(const InputParameters & parameters)
  : INSADStabilized3Eqn(parameters),
    _grad_c(adCoupledVectorValue("level_set_gradient")),
    _temp(adCoupledValue("temperature")),
    _grad_temp(adCoupledGradient("temperature")),
    _curvature(adCoupledValue("curvature")),
    _permeability(getADMaterialProperty<Real>("permeability")),
    _sigma(getParam<Real>("surface_tension")),
    _sigmaT(getParam<Real>("thermal_capillary")),
    _delta_function(getADMaterialProperty<Real>("delta_function")),
    _heaviside_function(getADMaterialProperty<Real>("heaviside_function")),
    _melt_pool_momentum_source(declareADProperty<RealVectorValue>("melt_pool_momentum_source")),
    _rho(getADMaterialProperty<Real>("rho")),
    _rho_l(getParam<Real>("rho_l")),
    _rho_g(getParam<Real>("rho_g")),
    _melt_pool_mass_rate(getADMaterialProperty<Real>("melt_pool_mass_rate")),
    _saturated_vapor_pressure(getADMaterialProperty<Real>("saturated_vapor_pressure")),
    _f_l(getADMaterialProperty<Real>("liquid_mass_fraction"))
{
}

void
INSMeltPoolMaterial::computeQpProperties()
{
  INSADStabilized3Eqn::computeQpProperties();

  _mass_strong_residual[_qp] +=
      _melt_pool_mass_rate[_qp] * _delta_function[_qp] * (1.0 / _rho_g - 1.0 / _rho_l);

  ADRealVectorValue darcy_term =
      -_permeability[_qp] * (1 - _heaviside_function[_qp]) * _velocity[_qp];

  _melt_pool_momentum_source[_qp] = darcy_term;

  ADRealVectorValue surface_tension_term = ADRealVectorValue(0.0);
  ADRealVectorValue thermalcapillary_term = ADRealVectorValue(0.0);
  RankTwoTensor iden(RankTwoTensor::initIdentity);
  ADRankTwoTensor proj;
  ADRealVectorValue normal = ADRealVectorValue(0.0);

  if (MetaPhysicL::raw_value(_f_l[_qp]) > libMesh::TOLERANCE &&
      MetaPhysicL::raw_value(_delta_function[_qp]) > libMesh::TOLERANCE)
  {
    normal = _grad_c[_qp] /
             (_grad_c[_qp] + RealVectorValue(libMesh::TOLERANCE * libMesh::TOLERANCE)).norm();

    proj.vectorOuterProduct(normal, normal);
    proj = iden - proj;
    surface_tension_term =
        _sigma * _curvature[_qp] *
        (_grad_c[_qp] + RealVectorValue(libMesh::TOLERANCE * libMesh::TOLERANCE));

    thermalcapillary_term = -proj * _grad_temp[_qp] * _sigmaT * _delta_function[_qp];

    _melt_pool_momentum_source[_qp] += -thermalcapillary_term + surface_tension_term;

    // Recoil Pressure
    _melt_pool_momentum_source[_qp] -=
        0.55 * _saturated_vapor_pressure[_qp] *
        (_grad_c[_qp] + RealVectorValue(libMesh::TOLERANCE * libMesh::TOLERANCE));
  }

  _momentum_strong_residual[_qp] -= _melt_pool_momentum_source[_qp];
}
