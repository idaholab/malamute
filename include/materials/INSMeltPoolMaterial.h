#pragma once

#include "INSADTauMaterial.h"

/**
 * This class computes extra residuals from melt pool for the INS equations.
 */
class INSMeltPoolMaterial : public INSADTauMaterial
{
public:
  static InputParameters validParams();

  INSMeltPoolMaterial(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// Gradient of the level set variable
  const ADVectorVariableValue & _grad_c;

  /// Temperature variable
  const ADVariableValue & _temp;

  /// Gradient of temperature variable
  const ADVariableGradient & _grad_temp;

  /// Curvature variable
  const ADVariableValue & _curvature;

  /// Permeability in Darcy term
  const ADMaterialProperty<Real> & _permeability;

  /// Surface tension coefficient
  const Real & _sigma;

  /// Thermal-capillary coefficient
  const Real & _sigmaT;

  /// Level set delta function
  const ADMaterialProperty<Real> & _delta_function;

  /// Level set Heaviside function
  const ADMaterialProperty<Real> & _heaviside_function;

  /// Melt pool momentum source
  ADMaterialProperty<RealVectorValue> & _melt_pool_momentum_source;
};
