/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADKernelValue.h"

/**
 * This class computes interface velocity due to phase change.
 */
class LevelSetPhaseChange : public ADKernelValue
{
public:
  static InputParameters validParams();

  LevelSetPhaseChange(const InputParameters & parameters);

protected:
  ADReal precomputeQpResidual() override;

  /// Delta function
  const ADMaterialProperty<Real> & _delta_function;

  /// Heaviside function
  const ADMaterialProperty<Real> & _heaviside_function;

  /// Mass transfer rate
  const ADMaterialProperty<Real> & _melt_pool_mass_rate;

  /// Liquid density
  const Real _rho_l;

  /// Gas density
  const Real _rho_g;
};
