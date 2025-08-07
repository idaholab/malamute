/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2025, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "INSMeltPoolMomentumSource.h"

registerMooseObject("MalamuteApp", INSMeltPoolMomentumSource);

InputParameters
INSMeltPoolMomentumSource::validParams()
{
  InputParameters params = ADVectorKernel::validParams();
  params.addClassDescription("Adds momentum source term of melt pool to the INS momentum equation");
  return params;
}

INSMeltPoolMomentumSource::INSMeltPoolMomentumSource(const InputParameters & parameters)
  : ADVectorKernelValue(parameters),
    _melt_pool_momentum_source(getADMaterialProperty<RealVectorValue>("melt_pool_momentum_source"))
{
}

ADRealVectorValue
INSMeltPoolMomentumSource::precomputeQpResidual()
{
  return -_melt_pool_momentum_source[_qp];
}
