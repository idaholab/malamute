/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2025, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "LevelSetPowderAddition.h"
#include "Function.h"

registerMooseObject("MalamuteApp", LevelSetPowderAddition);

InputParameters
LevelSetPowderAddition::validParams()
{
  InputParameters params = ADKernelValue::validParams();
  params.addClassDescription("Computes the powder addition to the melt pool");
  params.addParam<FunctionName>(
      "laser_location_x", 0, "The laser center function of x coordinate.");
  params.addParam<FunctionName>(
      "laser_location_y", 0, "The laser center function of y coordinate.");
  params.addParam<FunctionName>(
      "laser_location_z", 0, "The laser center function of z coordinate.");
  params.addRequiredParam<Real>("mass_rate", "Mass rate.");
  params.addRequiredParam<Real>("mass_radius", "Mass gaussian radius.");
  params.addParam<Real>("mass_scale", 1, "Mass gaussian scale.");
  params.addRequiredParam<Real>("powder_density", "Powder density.");
  params.addParam<Real>("eta_p", 1.0, "Powder catchment efficiency.");
  return params;
}

LevelSetPowderAddition::LevelSetPowderAddition(const InputParameters & parameters)
  : ADKernelValue(parameters),
    _delta_function(getADMaterialProperty<Real>("delta_function")),
    _laser_location_x(getFunction("laser_location_x")),
    _laser_location_y(getFunction("laser_location_y")),
    _laser_location_z(getFunction("laser_location_z")),
    _mass_rate(getParam<Real>("mass_rate")),
    _mass_radius(getParam<Real>("mass_radius")),
    _mass_scale(getParam<Real>("mass_scale")),
    _rho_p(getParam<Real>("powder_density")),
    _eta_p(getParam<Real>("eta_p"))
{
}

ADReal
LevelSetPowderAddition::precomputeQpResidual()
{
  using std::exp;
  Point p(0, 0, 0);
  RealVectorValue laser_location(_laser_location_x.value(_t, p),
                                 _laser_location_y.value(_t, p),
                                 _laser_location_z.value(_t, p));

  ADReal r = (_ad_q_point[_qp] - laser_location).norm();

  ADReal power_feed = 0;

  if (r <= _mass_radius)
    power_feed = _mass_scale * _eta_p * _mass_rate *
                 exp(-_mass_scale * Utility::pow<2>(r / _mass_radius)) / _rho_p / libMesh::pi /
                 Utility::pow<2>(_mass_radius);

  return _delta_function[_qp] * power_feed;
}
