#include "RadiationEnergyFluxBC.h"

registerMooseObject("BaldrApp", RadiationEnergyFluxBC);

InputParameters
RadiationEnergyFluxBC::validParams()
{
  InputParameters params = ADIntegratedBC::validParams();
  params.addClassDescription("Computes heat flux due to radiation");
  params.addParam<MaterialPropertyName>(
      "sb_constant", "sb_constant", "The stefan-boltzmann constant");
  params.addParam<MaterialPropertyName>("absorptivity", "abs", "The absorptivity of the material");
  params.addRequiredParam<Real>("ff_temp", "The far field temperature");
  return params;
}

RadiationEnergyFluxBC::RadiationEnergyFluxBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters),
    _sb_constant(getADMaterialProperty<Real>("sb_constant")),
    _absorptivity(getADMaterialProperty<Real>("absorptivity")),
    _ff_temp(getParam<Real>("ff_temp"))
{
}

ADReal
RadiationEnergyFluxBC::computeQpResidual()
{
  auto u2 = _u[_qp] * _u[_qp];
  auto u4 = u2 * u2;
  auto ff2 = _ff_temp * _ff_temp;
  auto ff4 = ff2 * ff2;
  return _test[_i][_qp] * _absorptivity[_qp] * _sb_constant[_qp] * (u4 - ff4);
}
