#pragma once

#include "ADIntegratedBC.h"

class RadiationEnergyFluxBC : public ADIntegratedBC
{
public:
  static InputParameters validParams();

  RadiationEnergyFluxBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  const ADMaterialProperty<Real> & _sb_constant;
  const ADMaterialProperty<Real> & _absorptivity;
  const Real _ff_temp;
};
