/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*               Copyright 2021, Battelle Energy Alliance, LLC              */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADMaterial.h"

/**
 * This class computes thermal properties in melt pool heat equations
 */
class LevelSetThermalMaterial : public ADMaterial
{
public:
  static InputParameters validParams();

  LevelSetThermalMaterial(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  /// Temperature variable
  const ADVariableValue & _temp;

  /// Heavisde function
  const ADMaterialProperty<Real> & _heaviside_function;

  /// Enthalpy
  ADMaterialProperty<Real> & _h;

  /// Thermal conductivity
  ADMaterialProperty<Real> & _k;

  /// Specifc heat
  ADMaterialProperty<Real> & _cp;

  /// Gas specific heat
  const Real & _c_g;

  /// Solid specific heat
  const Real & _c_s;

  /// Liquid specific heat
  const Real & _c_l;

  /// Gas thermal conductivity
  const Real & _k_g;

  /// Solid thermal conductivity
  const Real & _k_s;

  /// Liquid thermal conductivity
  const Real & _k_l;

  /// Latent heat
  const Real & _latent_heat;

  /// Solidus temperature
  const Real & _solidus_temperature;

  /// Liquid mass fraction
  const ADMaterialProperty<Real> & _f_l;

  /// Solid mass fraction
  const ADMaterialProperty<Real> & _f_s;

  /// Liquid volume fraction
  const ADMaterialProperty<Real> & _g_l;

  /// Solid volume fraction
  const ADMaterialProperty<Real> & _g_s;
};
