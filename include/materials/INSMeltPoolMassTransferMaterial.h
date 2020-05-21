#pragma once

#include "ADMaterial.h"

/**
 * This class computes extra residuals from mass transfer for the INS equations.
 */
class INSMeltPoolMassTransferMaterial : public ADMaterial
{
public:
  static InputParameters validParams();

  INSMeltPoolMassTransferMaterial(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// Temperature variable
  const ADVariableValue & _temp;

  /// Mass rate
  ADMaterialProperty<Real> & _melt_pool_mass_rate;

  /// Atomic weight
  const Real & _m;

  /// Boltzmann constant
  const Real & _boltzmann;

  /// Retrodiffusion coefficient
  const Real & _beta_r;

  /// Latent heat of vaporization
  const Real & _Lv;

  /// Vaporization temperature
  const Real & _vaporization_temperature;

  /// Reference pressure for vaporization
  const Real & _p0;
};
