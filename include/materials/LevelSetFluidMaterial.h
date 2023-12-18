/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADMaterial.h"
/**
 *This class computes fluid properties in melt pool heat equations
 */
class LevelSetFluidMaterial : public ADMaterial
{
public:
  static InputParameters validParams();

  LevelSetFluidMaterial(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// Level set Heaviside function
  const ADMaterialProperty<Real> & _heaviside_function;

  /// Density
  ADMaterialProperty<Real> & _rho;

  /// Viscosity
  ADMaterialProperty<Real> & _mu;

  /// Gas density
  const Real & _rho_g;

  /// Liquid density
  const Real & _rho_l;

  /// Solid density
  const Real & _rho_s;

  /// Gas viscosity
  const Real & _mu_g;

  /// Liquid viscosity
  const Real & _mu_l;

  /// Liquid mass fraction
  const ADMaterialProperty<Real> & _f_l;

  /// Solid mass fraction
  const ADMaterialProperty<Real> & _f_s;

  /// Liquid volume fraction
  const ADMaterialProperty<Real> & _g_l;

  /// Solid volume fraction
  const ADMaterialProperty<Real> & _g_s;

  /// Permeability in Darcy term
  ADMaterialProperty<Real> & _permeability;

  /// Constant in Darcy term
  const Real & _K0;
};
