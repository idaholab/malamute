/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADKernelValue.h"

/**
 * This class computes the momentum equation residual contribution for the source terms of the melt
 * pool for incompressible Navier-Stokes
 */
class INSMeltPoolMomentumSource : public ADVectorKernelValue
{
public:
  static InputParameters validParams();

  INSMeltPoolMomentumSource(const InputParameters & parameters);

protected:
  ADRealVectorValue precomputeQpResidual() override;

  const ADMaterialProperty<RealVectorValue> & _melt_pool_momentum_source;
};
