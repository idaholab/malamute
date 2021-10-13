#pragma once

#include "ADIntegratedBC.h"

class VaporRecoilPressureMomentumFluxBC : public ADIntegratedBC
{
public:
  static InputParameters validParams();

  VaporRecoilPressureMomentumFluxBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  const unsigned _component;
  const ADMaterialProperty<Real> & _rc_pressure;
};
