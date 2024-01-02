/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "PseudoSolidStress.h"

registerMooseObject("MalamuteApp", PseudoSolidStress);

InputParameters
PseudoSolidStress::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription(
      "Calculates a pseudo solid stress property based on coupled displacements.");
  params.addRequiredCoupledVar("disp_x", "The x displacement");
  params.addCoupledVar("disp_y", "The y displacement");
  params.addCoupledVar("disp_z", "The z displacement");
  return params;
}

PseudoSolidStress::PseudoSolidStress(const InputParameters & parameters)
  : ADMaterial(parameters),
    _stress_x(declareADProperty<RealVectorValue>("stress_x")),
    _stress_y(declareADProperty<RealVectorValue>("stress_y")),
    _stress_z(declareADProperty<RealVectorValue>("stress_z")),
    _grad_disp_x(adCoupledGradient("disp_x")),
    _grad_disp_y(this->isCoupled("disp_y") ? adCoupledGradient("disp_y") : adZeroGradient()),
    _grad_disp_z(this->isCoupled("disp_z") ? adCoupledGradient("disp_z") : adZeroGradient())
{
}

void
PseudoSolidStress::computeQpProperties()
{
  ADRealTensorValue def_gradient(_grad_disp_x[_qp], _grad_disp_y[_qp], _grad_disp_z[_qp]);
  const auto E = 0.5 * (def_gradient + def_gradient.transpose());
  RealTensorValue identity(1., 0, 0, 0, 1., 0, 0, 0, 1.);
  const auto S = 2. * E + E.tr() * identity;
  _stress_x[_qp] = S.row(0);
  _stress_y[_qp] = S.row(1);
  _stress_z[_qp] = S.row(2);
}
