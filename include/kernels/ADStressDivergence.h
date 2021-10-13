#pragma once

#include "ADKernel.h"
#include "MaterialProperty.h"

class ADStressDivergence : public ADKernel
{
public:
  static InputParameters validParams();

  ADStressDivergence(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual();

  ADMaterialProperty<RealVectorValue> const * _stress;
};
