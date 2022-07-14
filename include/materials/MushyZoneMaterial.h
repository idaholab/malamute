/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2022, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADMaterial.h"

/**
 * This class computes material properties in the mushy zone.
 */
class MushyZoneMaterial : public ADMaterial
{
public:
  static InputParameters validParams();

  MushyZoneMaterial(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// Temperature variable
  const ADVariableValue & _temp;

  /// Solidus temperature
  const Real & _solidus_temperature;

  /// Liquidus  temperature
  const Real & _liquidus_temperature;

  /// Liquid mass fraction
  ADMaterialProperty<Real> & _f_l;

  /// Solid mass fraction
  ADMaterialProperty<Real> & _f_s;

  /// Liquid volume fraction
  ADMaterialProperty<Real> & _g_l;

  /// Solid volume fraction
  ADMaterialProperty<Real> & _g_s;

  /// Solid density
  const Real & _rho_s;

  /// Liquid density
  const Real & _rho_l;
};
