/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*               Copyright 2021, Battelle Energy Alliance, LLC              */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "BaldrConvectedMesh.h"

registerMooseObject("MalamuteApp", BaldrConvectedMesh);

InputParameters
BaldrConvectedMesh::validParams()
{
  InputParameters params = ADVectorKernel::validParams();
  params.addClassDescription(
      "Corrects the convective derivative for situations in which the fluid mesh is dynamic.");
  params.addRequiredCoupledVar("disp_x", "The x displacement");
  params.addCoupledVar("disp_y", "The y displacement");
  params.addCoupledVar("disp_z", "The z displacement");
  params.addParam<MaterialPropertyName>("rho_name", "rho", "The name of the density");
  return params;
}

BaldrConvectedMesh::BaldrConvectedMesh(const InputParameters & parameters)
  : ADVectorKernel(parameters),
    _disp_x_dot(adCoupledDot("disp_x")),
    _disp_y_dot(isCoupled("disp_y") ? adCoupledDot("disp_y") : _ad_zero),
    _disp_z_dot(isCoupled("disp_z") ? adCoupledDot("disp_z") : _ad_zero),
    _rho(getADMaterialProperty<Real>("rho_name"))
{
}

ADReal
BaldrConvectedMesh::computeQpResidual()
{
  return _test[_i][_qp] * -_rho[_qp] * _grad_u[_qp] *
         ADRealVectorValue(_disp_x_dot[_qp], _disp_y_dot[_qp], _disp_z_dot[_qp]);
}
