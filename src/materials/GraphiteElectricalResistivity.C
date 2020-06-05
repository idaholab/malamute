#include "GraphiteElectricalResistivity.h"

#include "libmesh/utility.h"
#include "NonlinearSystemBase.h"
#include "TimeIntegrator.h"

registerMooseObject("FreyaApp", GraphiteElectricalResistivity);

InputParameters
GraphiteElectricalResistivity::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription(
      "Calculates the electrical resistivity as a function of temperature for "
      "AT 101 stainless steel in base SI units");
  params.addRequiredCoupledVar("temperature", "Coupled temperature variable");
  params.addParam<Real>("electrical_resistivity_scale_factor",
                        1.0,
                        "The scaling factor for graphite electrical resistivity");
  return params;
}

GraphiteElectricalResistivity::GraphiteElectricalResistivity(const InputParameters & parameters)
  : Material(parameters),
    _temperature(coupledValue("temperature")),
    _electrical_resistivity(declareProperty<Real>("electrical_resistivity")),
    _electrical_resistivity_dT(declareProperty<Real>("electrical_resistivity_dT")),
    _electrical_resistivity_scale_factor(getParam<Real>("electrical_resistivity_scale_factor"))
{
}

void
GraphiteElectricalResistivity::jacobianSetup()
{
  _check_temperature_now = false;
  int number_nonlinear_it =
      _fe_problem.getNonlinearSystemBase().getCurrentNonlinearIterationNumber();
  if (number_nonlinear_it == 0)
    _check_temperature_now = true;
}

void
GraphiteElectricalResistivity::computeQpProperties()
{
  if (_check_temperature_now)
  {
    if (_temperature[_qp] < 291.7)
      mooseError("The temperature in ",
                 _name,
                 " is below the calibration lower range limit at a value of ",
                 _temperature[_qp]);
    else if (_temperature[_qp] > 1873.6)
      mooseError("The temperature in ",
                 _name,
                 " is above the calibration upper range limit at a value of ",
                 _temperature[_qp]);
  }
  // Allow fall through to calculate the material properties
  computeElectricalResistivity();
}

void
GraphiteElectricalResistivity::computeElectricalResistivity()
{
  const Real electrical_resistivity = -2.705e-15 * Utility::pow<3>(_temperature[_qp]) +
                                      1.263e-11 * Utility::pow<2>(_temperature[_qp]) -
                                      1.836e-8 * _temperature[_qp] + 1.813e-5; // in Ohm/m

  const Real electrical_resistivity_dT = 3.0 * 1.575e-15 * Utility::pow<2>(_temperature[_qp]) -
                                         2.0 * 3.236e-12 * _temperature[_qp] + 2.724e-09;

  _electrical_resistivity[_qp] = electrical_resistivity * _electrical_resistivity_scale_factor;
  _electrical_resistivity_dT[_qp] =
      electrical_resistivity_dT * _electrical_resistivity_scale_factor;
}
