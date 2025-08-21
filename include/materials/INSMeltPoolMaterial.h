/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2025, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "INSADStabilized3Eqn.h"

/**
 * This class computes extra residuals from melt pool for the INS equations.
 */
class INSMeltPoolMaterial : public INSADStabilized3Eqn
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

  /// Density
  const ADMaterialProperty<Real> & _rho;

  /// Liquid density
  const Real _rho_l;

  /// Gas density
  const Real _rho_g;

  /// Mass transfer rate
  const ADMaterialProperty<Real> & _melt_pool_mass_rate;

  /// Saturated vapor pressure
  const ADMaterialProperty<Real> & _saturated_vapor_pressure;

  /// Liquid mass fraction
  const ADMaterialProperty<Real> & _f_l;
};
