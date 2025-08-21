/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2025, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADGaussianHeatSourceBase.h"
#include "Function.h"

/**
 * Gaussian heat source distribution. The motion of its center follows user-specified path functions
 * in space
 */
class ADFunctionPathGaussianHeatSource : public ADGaussianHeatSourceBase
{
public:
  static InputParameters validParams();

  ADFunctionPathGaussianHeatSource(const InputParameters & parameters);

protected:
  virtual void
  computeHeatSourceCenterAtTime(Real & x, Real & y, Real & z, const Real & time) override;

  virtual void computeHeatSourceMovingSpeedAtTime(const Real & time) override;

  /// path of the heat source, x, y, z components
  const Function & _function_x;
  const Function & _function_y;
  const Function & _function_z;
};
