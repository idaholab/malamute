#include "PenaltyDisplaceBoundaryBC.h"

registerMooseObject("BaldrApp", PenaltyDisplaceBoundaryBC);

InputParameters
PenaltyDisplaceBoundaryBC::validParams()
{
  InputParameters params = ADIntegratedBC::validParams();
  params.addClassDescription("For displacing a boundary");
  params.addRequiredCoupledVar("disp_x", "The x displacement");
  params.addRequiredCoupledVar("vel_x", "The x velocity");
  params.addCoupledVar("disp_y", "The y displacement");
  params.addCoupledVar("vel_y", "The y velocity");
  params.addCoupledVar("disp_z", "The z displacement");
  params.addCoupledVar("vel_z", "The z velocity");
  params.addParam<Real>("penalty", 1e6, "The penalty coefficient");
  return params;
}

PenaltyDisplaceBoundaryBC::PenaltyDisplaceBoundaryBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters),
    _vel_x(adCoupledValue("vel_x")),
    _vel_y(this->isCoupled("vel_y") ? adCoupledValue("vel_y") : adZeroValue()),
    _vel_z(this->isCoupled("vel_z") ? adCoupledValue("vel_z") : adZeroValue()),
    _disp_x_dot(adCoupledDot("disp_x")),
    _disp_y_dot(this->isCoupled("disp_y") ? adCoupledDot("disp_y") : adZeroValue()),
    _disp_z_dot(this->isCoupled("disp_z") ? adCoupledDot("disp_z") : adZeroValue()),
    _penalty(getParam<Real>("penalty"))
{
}

ADReal
PenaltyDisplaceBoundaryBC::computeQpResidual()
{
  return _test[_i][_qp] * _penalty * _normals[_qp] *
         ADRealVectorValue(_vel_x[_qp] - _disp_x_dot[_qp],
                           _vel_y[_qp] - _disp_y_dot[_qp],
                           _vel_z[_qp] - _disp_z_dot[_qp]);
}
