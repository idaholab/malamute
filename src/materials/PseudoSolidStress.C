//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PseudoSolidStress.h"

registerADMooseObject("LaserWeldingApp", PseudoSolidStress);

defineADValidParams(PseudoSolidStress,
                    ADMaterial,
                    params.addRequiredCoupledVar("disp_x", "The x displacement");
                    params.addCoupledVar("disp_y", "The y displacement");
                    params.addCoupledVar("disp_z", "The z displacement"););

template <ComputeStage compute_stage>
PseudoSolidStress<compute_stage>::PseudoSolidStress(const InputParameters & parameters)
  : ADMaterial<compute_stage>(parameters),
    _stress_x(adDeclareADProperty<RealVectorValue>("stress_x")),
    _stress_y(adDeclareADProperty<RealVectorValue>("stress_y")),
    _stress_z(adDeclareADProperty<RealVectorValue>("stress_z")),
    _grad_disp_x(adCoupledGradient("disp_x")),
    _grad_disp_y(this->isCoupled("disp_y") ? adCoupledGradient("disp_y") : adZeroGradient()),
    _grad_disp_z(this->isCoupled("disp_z") ? adCoupledGradient("disp_z") : adZeroGradient())
{
}

template <ComputeStage compute_stage>
void
PseudoSolidStress<compute_stage>::computeQpProperties()
{
  typedef typename Moose::template ValueType<compute_stage, TensorValue<Real>>::type LocalTensor;
  LocalTensor def_gradient(_grad_disp_x[_qp], _grad_disp_y[_qp], _grad_disp_z[_qp]);
  const auto E =
      0.5 * (def_gradient + def_gradient.transpose() - def_gradient * def_gradient.transpose());
  TensorValue<Real> identity(1., 0, 0, 0, 1., 0, 0, 0, 1.);
  const auto S = 2. * E + E.tr() * identity;
  _stress_x[_qp] = S.row(0);
  _stress_y[_qp] = S.row(1);
  _stress_z[_qp] = S.row(2);
  // _stress_x[_qp] = def_gradient.row(0);
  // _stress_y[_qp] = def_gradient.row(1);
  // _stress_z[_qp] = def_gradient.row(2);
}
