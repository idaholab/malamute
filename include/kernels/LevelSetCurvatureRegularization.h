#pragma once

#include "ADKernel.h"

/**
 * This class computes regularized interface curvature that is represented by a level set
 * function.
 */
class LevelSetCurvatureRegularization : public ADKernel
{
public:
  static InputParameters validParams();

  LevelSetCurvatureRegularization(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

  /// Gradient of regularized gradient of level set
  const ADVectorVariableValue & _grad_c;

  /// regulization parameter
  const Real _varepsilon;
};
