#pragma once

#include "ADMaterial.h"

/**
 * This class computes Heaviside function given by a level set
 */
class LevelSetHeavisideFunction : public ADMaterial
{
public:
  static InputParameters validParams();

  LevelSetHeavisideFunction(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// Level set variable
  const ADVariableValue & _c;

  /// Heaviside function
  ADMaterialProperty<Real> & _heaviside_function;
};
