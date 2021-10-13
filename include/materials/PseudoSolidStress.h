#pragma once

#include "ADMaterial.h"

/**
 * A material that couples a material property
 */
class PseudoSolidStress : public ADMaterial
{
public:
  static InputParameters validParams();

  PseudoSolidStress(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

  ADMaterialProperty<RealVectorValue> & _stress_x;
  ADMaterialProperty<RealVectorValue> & _stress_y;
  ADMaterialProperty<RealVectorValue> & _stress_z;
  const ADVariableGradient & _grad_disp_x;
  const ADVariableGradient & _grad_disp_y;
  const ADVariableGradient & _grad_disp_z;
};
