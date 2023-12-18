/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADGaussianHeatSourceBase.h"
#include "Function.h"

/**
 * Gaussian heat source distribution. The motion of its center follows a user-specified velocity
 * profile
 */
class ADVelocityGaussianHeatSource : public ADGaussianHeatSourceBase
{
public:
  static InputParameters validParams();

  ADVelocityGaussianHeatSource(const InputParameters & parameters);

protected:
  virtual void
  computeHeatSourceCenterAtTime(Real & x, Real & y, Real & z, const Real & time) override;

  virtual void computeHeatSourceMovingSpeedAtTime(const Real & time) override;

  /// previous time
  Real _prev_time;

  /// position at previous time
  Real _x_prev, _y_prev, _z_prev;

  /// function of scanning speed along three directions
  const Function & _function_vx;
  const Function & _function_vy;
  const Function & _function_vz;

  /// stores the velocity at the current step
  Real _vx, _vy, _vz;
};
