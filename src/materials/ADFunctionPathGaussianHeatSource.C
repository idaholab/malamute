/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "ADFunctionPathGaussianHeatSource.h"

#include "Function.h"

registerMooseObject("MalamuteApp", ADFunctionPathGaussianHeatSource);

InputParameters
ADFunctionPathGaussianHeatSource::validParams()
{
  InputParameters params = ADGaussianHeatSourceBase::validParams();
  params.addParam<FunctionName>("function_x",
                                "0",
                                "The x component of the center of the heating spot as a function "
                                "of time, length unit is [mm], time unit is [ms].");
  params.addParam<FunctionName>("function_y",
                                "0",
                                "The y component of the center of the heating spot as a function "
                                "of time, length unit is [mm], time unit is [ms].");
  params.addParam<FunctionName>("function_z",
                                "0",
                                "The z component of the center of the heating spot as a function "
                                "of time, length unit is [mm], time unit is [ms].");

  params.addClassDescription(
      "Gaussian heat source whose center moves along a specified function path.");

  return params;
}

ADFunctionPathGaussianHeatSource::ADFunctionPathGaussianHeatSource(const InputParameters & parameters)
  : ADGaussianHeatSourceBase(parameters),
    _function_x(getFunction("function_x")),
    _function_y(getFunction("function_y")),
    _function_z(getFunction("function_z"))
{
}

void
ADFunctionPathGaussianHeatSource::computeHeatSourceCenterAtTime(Real & x,
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
ADFunctionPathGaussianHeatSource::computeHeatSourceMovingSpeedAtTime(const Real & time)
{
  const static Point dummy;
  Real vx = _function_x.timeDerivative(time);
  Real vy = _function_y.timeDerivative(time);
  Real vz = _function_z.timeDerivative(time);
  _scan_speed = std::sqrt(vx * vx + vy * vy + vz * vz);
}
