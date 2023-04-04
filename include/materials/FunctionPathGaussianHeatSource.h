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
#include "Function.h"

/**
 * Double ellipsoid heat source distribution.
 */
class FunctionPathGaussianHeatSource : public GaussianHeatSourceBase
{
public:
  static InputParameters validParams();

  FunctionPathGaussianHeatSource(const InputParameters & parameters);

protected:
  virtual void
  computeHeatSourceCenterAtTime(Real & x, Real & y, Real & z, const Real & time) override;

  virtual void computeHeatSourceMovingSpeedAtTime(const Real & time) override;

  /// path of the heat source, x, y, z components
  const Function & _function_x;
  const Function & _function_y;
  const Function & _function_z;
};
