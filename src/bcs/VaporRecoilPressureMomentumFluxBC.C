//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "VaporRecoilPressureMomentumFluxBC.h"

registerADMooseObject("LaserWeldingApp", VaporRecoilPressureMomentumFluxBC);

defineADValidParams(
    VaporRecoilPressureMomentumFluxBC,
    ADIntegratedBC,
    params.addClassDescription("Vapor recoil pressure momentum flux");
    params.addRequiredParam<unsigned>("component", "The velocity component");
    params.addParam<MaterialPropertyName>("rc_pressure_name", "rc_pressure", "The recoil pressure");
    params.addCoupledVar("temperature", "The temperature on which the recoil pressure depends"););

template <ComputeStage compute_stage>
VaporRecoilPressureMomentumFluxBC<compute_stage>::VaporRecoilPressureMomentumFluxBC(
    const InputParameters & parameters)
  : ADIntegratedBC<compute_stage>(parameters),
    _component(adGetParam<unsigned>("component")),
    _rc_pressure(adGetADMaterialProperty<Real>("rc_pressure_name"))
{
}

template <ComputeStage compute_stage>
ADResidual
VaporRecoilPressureMomentumFluxBC<compute_stage>::computeQpResidual()
{
  return _test[_i][_qp] * std::abs(_normals[_qp](_component)) * _rc_pressure[_qp];
}
