//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PenaltyDisplaceBoundaryBC.h"

registerADMooseObject("LaserWeldingApp", PenaltyDisplaceBoundaryBC);

defineADValidParams(PenaltyDisplaceBoundaryBC,
                    ADIntegratedBC,
                    params.addClassDescription("For displacing a boundary");
                    params.addRequiredCoupledVar("disp_x", "The x displacement");
                    params.addRequiredCoupledVar("vel_x", "The x velocity");
                    params.addCoupledVar("disp_y", "The y displacement");
                    params.addCoupledVar("vel_y", "The y velocity");
                    params.addCoupledVar("disp_z", "The z displacement");
                    params.addCoupledVar("vel_z", "The z velocity");
                    params.addParam<Real>("penalty", 1e6, "The penalty coefficient"););

template <ComputeStage compute_stage>
PenaltyDisplaceBoundaryBC<compute_stage>::PenaltyDisplaceBoundaryBC(
    const InputParameters & parameters)
  : ADIntegratedBC<compute_stage>(parameters),
    _vel_x(adCoupledValue("vel_x")),
    _vel_y(this->isCoupled("vel_y") ? adCoupledValue("vel_y") : adZeroValue()),
    _vel_z(this->isCoupled("vel_z") ? adCoupledValue("vel_") : adZeroValue()),
    _disp_x_dot(adCoupledDot("disp_x")),
    _disp_y_dot(this->isCoupled("disp_y") ? adCoupledDot("disp_y") : adZeroValue()),
    _disp_z_dot(this->isCoupled("disp_z") ? adCoupledDot("disp_z") : adZeroValue()),
    _penalty(adGetParam<Real>("penalty"))
{
}

template <ComputeStage compute_stage>
typename Moose::RealType<compute_stage>::type
PenaltyDisplaceBoundaryBC<compute_stage>::computeQpResidual()
{
  return _test[_i][_qp] * _penalty * _normals[_qp] *
         typename Moose::ValueType<compute_stage, VectorValue<Real>>::type(
             _vel_x[_qp] - _disp_x_dot[_qp],
             _vel_y[_qp] - _disp_y_dot[_qp],
             _vel_z[_qp] - _disp_z_dot[_qp]);
}
