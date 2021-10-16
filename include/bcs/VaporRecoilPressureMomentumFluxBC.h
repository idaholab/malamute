#pragma once

#include "ADVectorIntegratedBC.h"

class VaporRecoilPressureMomentumFluxBC : public ADVectorIntegratedBC
{
public:
  static InputParameters validParams();

  VaporRecoilPressureMomentumFluxBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  const ADMaterialProperty<Real> & _rc_pressure;
};
