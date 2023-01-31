/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADKernelValue.h"

/**
 * This class computes the powder addition to the melt pool.
 */
class LevelSetPowderAddition : public ADKernelValue
{
public:
  static InputParameters validParams();

  LevelSetPowderAddition(const InputParameters & parameters);

protected:
  ADReal precomputeQpResidual() override;

  /// Delta function
  const ADMaterialProperty<Real> & _delta_function;

  /// Function of laser location in x coordinate
  const Function & _laser_location_x;

  /// Function of laser location in x coordinate
  const Function & _laser_location_y;

  /// Function of laser location in x coordinate
  const Function & _laser_location_z;

  /// Mass addition rate
  const Real _mass_rate;

  /// Mass addition gaussian radius
  const Real _mass_radius;

  /// Mass addition gaussian scale
  const Real _mass_scale;

  /// Powder density
  const Real _rho_p;

  /// powder catchment efficiency
  const Real _eta_p;
};
