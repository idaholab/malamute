/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2025, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "Material.h"

/**
 * Rosenthal temperature distribution.
 */
template <bool is_ad>
class RosenthalTemperatureSourceTempl : public Material
{
public:
  static InputParameters validParams();

  RosenthalTemperatureSourceTempl(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  /// Laser power
  const Real _P;
  /// Scanning velocity
  const Real _V;
  /// Ambient temperature away from the surface
  const Real _T0;
  /// Melting temperature
  const Real _Tm;
  /// Initial heat source location
  const Real _x0;

  const GenericMaterialProperty<Real, is_ad> & _thermal_conductivity;
  const GenericMaterialProperty<Real, is_ad> & _specific_heat;
  const GenericMaterialProperty<Real, is_ad> & _density;
  const GenericMaterialProperty<Real, is_ad> & _absorptivity;

  GenericMaterialProperty<Real, is_ad> & _thermal_diffusivity;
  GenericMaterialProperty<Real, is_ad> & _temp_source;
  GenericMaterialProperty<Real, is_ad> & _meltpool_depth;
  GenericMaterialProperty<Real, is_ad> & _meltpool_width;
};

typedef RosenthalTemperatureSourceTempl<false> RosenthalTemperatureSource;
typedef RosenthalTemperatureSourceTempl<true> ADRosenthalTemperatureSource;
