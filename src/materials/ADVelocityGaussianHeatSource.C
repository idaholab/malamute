/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "ADVelocityGaussianHeatSource.h"

registerMooseObject("MalamuteApp", ADVelocityGaussianHeatSource);

InputParameters
ADVelocityGaussianHeatSource::validParams()
{
  InputParameters params = ADGaussianHeatSourceBase::validParams();
  params.addParam<Real>(
      "x0", 0, "The x component of the initial center of the heating spot, speed unit is [mm/ms].");
  params.addParam<Real>(
      "y0", 0, "The y component of the initial center of the heating spot, speed unit is [mm/ms].");
  params.addParam<Real>(
      "z0", 0, "The z component of the initial center of the heating spot, speed unit is [mm/ms].");

  params.addParam<FunctionName>(
      "function_vx",
      "0",
      "The function of x component of the center of the heating spot moving speed");
  params.addParam<FunctionName>(
      "function_vy",
      "0",
      "The function of y component of the center of the heating spot moving speed");
  params.addParam<FunctionName>(
      "function_vz",
      "0",
      "The function of z component of the center of the heating spot moving speed");

  params.addClassDescription("Gaussian heat source whose center moves with a specified velocity.");

  return params;
}

ADVelocityGaussianHeatSource::ADVelocityGaussianHeatSource(const InputParameters & parameters)
  : ADGaussianHeatSourceBase(parameters),
    _prev_time(0),
    _x_prev(getParam<Real>("x0")),
    _y_prev(getParam<Real>("y0")),
    _z_prev(getParam<Real>("z0")),
    _function_vx(getFunction("function_vx")),
    _function_vy(getFunction("function_vy")),
    _function_vz(getFunction("function_vz"))
{
}

void
ADVelocityGaussianHeatSource::computeHeatSourceCenterAtTime(Real & x,
                                                            Real & y,
                                                            Real & z,
                                                            const Real & time)
{
  Real delta_t = time - _prev_time;
  if (delta_t > 0.0)
  {
    const static Point dummy;
    _vx = _function_vx.value(time, dummy);
    _vy = _function_vy.value(time, dummy);
    _vz = _function_vz.value(time, dummy);

    x = _x_prev + _vx * delta_t;
    y = _y_prev + _vy * delta_t;
    z = _z_prev + _vz * delta_t;

    // march forward time
    _prev_time = time;
    // update position
    _x_prev += _vx * delta_t;
    _y_prev += _vy * delta_t;
    _z_prev += _vz * delta_t;
  }
  else
  {
    x = _x_prev;
    y = _y_prev;
    z = _z_prev;
  }
}

void
ADVelocityGaussianHeatSource::computeHeatSourceMovingSpeedAtTime(const Real & /*time*/)
{
  _scan_speed = std::sqrt(_vx * _vx + _vy * _vy + _vz * _vz);
}
