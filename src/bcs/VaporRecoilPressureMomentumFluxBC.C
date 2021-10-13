#include "VaporRecoilPressureMomentumFluxBC.h"

registerMooseObject("BaldrApp", VaporRecoilPressureMomentumFluxBC);

InputParameters
VaporRecoilPressureMomentumFluxBC::validParams()
{
  InputParameters params = ADIntegratedBC::validParams();
  params.addClassDescription("Vapor recoil pressure momentum flux");
  params.addRequiredParam<unsigned>("component", "The velocity component");
  params.addParam<MaterialPropertyName>("rc_pressure_name", "rc_pressure", "The recoil pressure");
  params.addCoupledVar("temperature", "The temperature on which the recoil pressure depends");
  return params;
}

VaporRecoilPressureMomentumFluxBC::VaporRecoilPressureMomentumFluxBC(
    const InputParameters & parameters)
  : ADIntegratedBC(parameters),
    _component(getParam<unsigned>("component")),
    _rc_pressure(getADMaterialProperty<Real>("rc_pressure_name"))
{
}

ADReal
VaporRecoilPressureMomentumFluxBC::computeQpResidual()
{
  return _test[_i][_qp] * std::abs(_normals[_qp](_component)) * _rc_pressure[_qp];
}
