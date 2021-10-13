#pragma once

#include "ADIntegratedBC.h"

class SurfaceTensionBC : public ADIntegratedBC
{
public:
  static InputParameters validParams();

  SurfaceTensionBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  const unsigned _component;
  const ADMaterialProperty<RealVectorValue> & _surface_term_curvature;
  const ADMaterialProperty<RealVectorValue> & _surface_term_gradient1;
  const ADMaterialProperty<RealVectorValue> & _surface_term_gradient2;
};
