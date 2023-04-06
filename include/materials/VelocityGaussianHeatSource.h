/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "GaussianHeatSourceBase.h"

/**
 * Double ellipsoid heat source distribution.
 */
class VelocityGaussianHeatSource : public GaussianHeatSourceBase
{
public:
  static InputParameters validParams();

  VelocityGaussianHeatSource(const InputParameters & parameters);

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
