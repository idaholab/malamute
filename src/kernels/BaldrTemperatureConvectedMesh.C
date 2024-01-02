/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "BaldrTemperatureConvectedMesh.h"

registerMooseObject("MalamuteApp", BaldrTemperatureConvectedMesh);

InputParameters
BaldrTemperatureConvectedMesh::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addClassDescription(
      "Corrects the convective derivative for situations in which the fluid mesh is dynamic.");
  params.addRequiredCoupledVar("disp_x", "The x displacement");
  params.addCoupledVar("disp_y", "The y displacement");
  params.addCoupledVar("disp_z", "The z displacement");
  params.addParam<MaterialPropertyName>("rho_name", "rho", "The name of the density");
  params.addParam<MaterialPropertyName>("cp_name", "cp", "The name of the specific heat");
  return params;
}

BaldrTemperatureConvectedMesh::BaldrTemperatureConvectedMesh(const InputParameters & parameters)
  : ADKernel(parameters),
    _disp_x_dot(adCoupledDot("disp_x")),
    _disp_y_dot(isCoupled("disp_y") ? adCoupledDot("disp_y") : _ad_zero),
    _disp_z_dot(isCoupled("disp_z") ? adCoupledDot("disp_z") : _ad_zero),
    _rho(getADMaterialProperty<Real>("rho_name")),
    _cp(getADMaterialProperty<Real>("cp_name"))
{
}

ADReal
BaldrTemperatureConvectedMesh::computeQpResidual()
{
  return _test[_i][_qp] * -_rho[_qp] * _cp[_qp] *
         ADRealVectorValue(_disp_x_dot[_qp], _disp_y_dot[_qp], _disp_z_dot[_qp]) * _grad_u[_qp];
}
