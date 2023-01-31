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
 * This class computes the laser heat source and heat loss in the melt pool heat equation.
 */
class MeltPoolHeatSource : public ADKernelValue
{
public:
  static InputParameters validParams();

  MeltPoolHeatSource(const InputParameters & parameters);

protected:
  ADReal precomputeQpResidual() override;

  /// Delta function
  const ADMaterialProperty<Real> & _delta_function;

  /// Laser power
  const Real & _power;

  /// Absorption coefficient
  const Real & _alpha;

  /// Laser beam radius
  const Real & _Rb;

  /// Heat transfer coefficient
  const Real & _Ah;

  /// Stefan Boltzmann constant
  const Real & _stefan_boltzmann;

  /// Material emissivity
  const Real & _varepsilon;

  /// Ambient temperature
  const Real & _T0;

  /// Function of laser location in x coordinate
  const Function & _laser_location_x;

  /// Function of laser location in x coordinate
  const Function & _laser_location_y;

  /// Function of laser location in x coordinate
  const Function & _laser_location_z;

  /// Density
  const ADMaterialProperty<Real> & _rho;

  /// Mass transfer rate
  const ADMaterialProperty<Real> & _melt_pool_mass_rate;

  /// Specific heat
  const ADMaterialProperty<Real> & _cp;

  /// Latent heat of vaporization
  const Real _Lv;

  /// Liquid density
  const Real _rho_l;

  /// Gas density
  const Real _rho_g;
};
