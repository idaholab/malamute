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
