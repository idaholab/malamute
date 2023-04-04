/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "FunctionPathGaussianHeatSource.h"

#include "Function.h"

registerMooseObject("MalamuteApp", FunctionPathGaussianHeatSource);

InputParameters
FunctionPathGaussianHeatSource::validParams()
{
  InputParameters params = GaussianHeatSourceBase::validParams();
  params.addParam<FunctionName>(
      "function_x", "0", "The x component of the center of the heating spot as a function of time");
  params.addParam<FunctionName>(
      "function_y", "0", "The y component of the center of the heating spot as a function of time");
  params.addParam<FunctionName>(
      "function_z", "0", "The z component of the center of the heating spot as a function of time");

  params.addClassDescription("Double ellipsoid volumetric source heat with function path.");

  return params;
}

FunctionPathGaussianHeatSource::FunctionPathGaussianHeatSource(const InputParameters & parameters)
  : GaussianHeatSourceBase(parameters),
    _function_x(getFunction("function_x")),
    _function_y(getFunction("function_y")),
    _function_z(getFunction("function_z"))
{
}

void
FunctionPathGaussianHeatSource::computeHeatSourceCenterAtTime(Real & x,
                                                              Real & y,
                                                              Real & z,
                                                              const Real & time)
{
  const static Point dummy;
  x = _function_x.value(time, dummy);
  y = _function_y.value(time, dummy);
  z = _function_z.value(time, dummy);
}

void
FunctionPathGaussianHeatSource::computeHeatSourceMovingSpeedAtTime(const Real & time)
{
  const static Point dummy;
  Real vx = _function_x.timeDerivative(time);
  Real vy = _function_y.timeDerivative(time);
  Real vz = _function_z.timeDerivative(time);
  _scan_speed = std::sqrt(vx * vx + vy * vy + vz * vz);
}
