#include "StainlessSteelElectricalResistivity.h"

#include "libmesh/utility.h"
#include "NonlinearSystemBase.h"
#include "TimeIntegrator.h"

registerMooseObject("FreyaApp", StainlessSteelElectricalResistivity);

InputParameters
StainlessSteelElectricalResistivity::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription(
      "Calculates the electrical resistivity as a function of temperature for "
      "AISI 304 stainless steel in base SI units");
  params.addRequiredCoupledVar("temperature", "Coupled temperature variable");
  params.addParam<Real>("electrical_resistivity_scale_factor",
                        1.0,
                        "The scaling factor for stainless steel electrical resistivity");
  return params;
}

StainlessSteelElectricalResistivity::StainlessSteelElectricalResistivity(
    const InputParameters & parameters)
  : Material(parameters),
    _temperature(coupledValue("temperature")),
    _electrical_resistivity(declareProperty<Real>("electrical_resistivity")),
    _electrical_resistivity_dT(declareProperty<Real>("electrical_resistivity_dT")),
    _electrical_resistivity_scale_factor(getParam<Real>("electrical_resistivity_scale_factor"))
{
}

void
StainlessSteelElectricalResistivity::jacobianSetup()
{
  _check_temperature_now = false;
  int number_nonlinear_it =
      _fe_problem.getNonlinearSystemBase().getCurrentNonlinearIterationNumber();
  if (number_nonlinear_it == 0)
    _check_temperature_now = true;
}

void
StainlessSteelElectricalResistivity::computeQpProperties()
{
  if (_check_temperature_now)
  {
    if (_temperature[_qp] < 296.8)
      mooseError("The temperature in ",
                 _name,
                 " is below the calibration lower range limit at a value of ",
                 _temperature[_qp]);
    else if (_temperature[_qp] > 1029.0)
      mooseError("The temperature in ",
                 _name,
                 " is above the calibration upper range limit at a value of ",
                 _temperature[_qp]);
  }
  // Allow fall through to calculate the material properties
  computeElectricalResistivity();
}

void
StainlessSteelElectricalResistivity::computeElectricalResistivity()
{
  const Real electrical_resistivity = 1.575e-15 * Utility::pow<3>(_temperature[_qp]) -
                                      3.236e-12 * Utility::pow<2>(_temperature[_qp]) +
                                      2.724e-09 * _temperature[_qp] + 1.364e-07; // in Ohm/m
  _electrical_resistivity[_qp] = electrical_resistivity * _electrical_resistivity_scale_factor;
  const Real electrical_resistivity_dT = 3.0 * 1.575e-15 * Utility::pow<2>(_temperature[_qp]) -
                                         2.0 * 3.236e-12 * _temperature[_qp] + 2.724e-09;
  _electrical_resistivity_dT[_qp] =
      electrical_resistivity_dT * _electrical_resistivity_scale_factor;
}
