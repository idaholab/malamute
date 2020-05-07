#include "INSMeltPoolMaterial.h"

registerADMooseObject("ValhallaApp", INSMeltPoolMaterial);

InputParameters
INSMeltPoolMaterial::validParams()
{
  InputParameters params = INSADTauMaterial::validParams();
  params.addClassDescription("Computes extra residuals from melt pool for the INS equations.");
  params.addRequiredCoupledVar("level_set_gradient", "Regularized gradient of Level set variable");
  params.addRequiredCoupledVar("temperature", "Temperature variable");
  params.addRequiredCoupledVar("curvature", "Regularized curvature variable");
  params.addRequiredParam<Real>("surface_tension", "Surface tension coefficient.");
  params.addRequiredParam<Real>("thermal_capillary", "Thermalcapillary coefficient.");
  return params;
}

INSMeltPoolMaterial::INSMeltPoolMaterial(const InputParameters & parameters)
  : INSADTauMaterial(parameters),
    _grad_c(adCoupledVectorValue("level_set_gradient")),
    _temp(adCoupledValue("temperature")),
    _grad_temp(adCoupledGradient("temperature")),
    _curvature(adCoupledValue("curvature")),
    _permeability(getADMaterialProperty<Real>("permeability")),
    _sigma(getParam<Real>("surface_tension")),
    _sigmaT(getParam<Real>("thermal_capillary")),
    _delta_function(getADMaterialProperty<Real>("delta_function")),
    _heaviside_function(getADMaterialProperty<Real>("heaviside_function")),
    _melt_pool_momentum_source(declareADProperty<RealVectorValue>("melt_pool_momentum_source"))
{
}

void
INSMeltPoolMaterial::computeQpProperties()
{
  INSADTauMaterial::computeQpProperties();

  ADRealVectorValue normal =
      _grad_c[_qp] /
      (_grad_c[_qp] + RealVectorValue(libMesh::TOLERANCE * libMesh::TOLERANCE)).norm();

  RankTwoTensor iden(RankTwoTensor::initIdentity);
  ADRankTwoTensor proj;
  proj.vectorOuterProduct(normal, normal);
  proj = iden - proj;

  ADRealVectorValue darcy_term =
      -_permeability[_qp] * (1 - _heaviside_function[_qp]) * _velocity[_qp];
  ADRealVectorValue surface_tension_term = _sigma * _curvature[_qp] * _grad_c[_qp];
  ADRealVectorValue thermalcapillary_term =
      -proj * _grad_temp[_qp] * _sigmaT * _delta_function[_qp];

  _melt_pool_momentum_source[_qp] = -thermalcapillary_term + surface_tension_term + darcy_term;

  _momentum_strong_residual[_qp] -= _melt_pool_momentum_source[_qp];
}
