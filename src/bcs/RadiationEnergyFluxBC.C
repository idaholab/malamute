//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "RadiationEnergyFluxBC.h"

registerADMooseObject("LaserWeldingApp", RadiationEnergyFluxBC);

defineADValidParams(RadiationEnergyFluxBC,
                    ADIntegratedBC,
                    params.addClassDescription("Computes heat flux due to radiation");
                    params.addParam<MaterialPropertyName>("sb_constant",
                                                          "sb_constant",
                                                          "The stefan-boltzmann constant");
                    params.addParam<MaterialPropertyName>("absorptivity",
                                                          "abs",
                                                          "The absorptivity of the material");
                    params.addRequiredParam<Real>("ff_temp", "The far field temperature"););

template <ComputeStage compute_stage>
RadiationEnergyFluxBC<compute_stage>::RadiationEnergyFluxBC(const InputParameters & parameters)
  : ADIntegratedBC<compute_stage>(parameters),
    _sb_constant(adGetADMaterialProperty<Real>("sb_constant")),
    _absorptivity(adGetADMaterialProperty<Real>("absorptivity")),
    _ff_temp(adGetParam<Real>("ff_temp"))
{
}

template <ComputeStage compute_stage>
ADResidual
RadiationEnergyFluxBC<compute_stage>::computeQpResidual()
{
  auto u2 = _u[_qp] * _u[_qp];
  auto u4 = u2 * u2;
  auto ff2 = _ff_temp * _ff_temp;
  auto ff4 = ff2 * ff2;
  return _test[_i][_qp] * _absorptivity[_qp] * _sb_constant[_qp] * (u4 - ff4);
}
