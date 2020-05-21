#pragma once

#include "ADKernelGrad.h"

/**
 * Implements the re-initialization equation that uses regularized gradient.
 */
class LevelSetGradientRegularizationReinitialization : public ADKernelGrad
{
public:
  static InputParameters validParams();

  LevelSetGradientRegularizationReinitialization(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  /// Regularized gradient of the level set variable at time, \tau = 0.
  const VectorVariableValue & _grad_c;

  /// Interface thickness
  const Real & _epsilon;
};
