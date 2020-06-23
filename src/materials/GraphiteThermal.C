#include "GraphiteThermal.h"

#include "libmesh/utility.h"
#include "NonlinearSystemBase.h"
#include "TimeIntegrator.h"

registerMooseObject("FreyaApp", GraphiteThermal);
registerMooseObject("FreyaApp", ADGraphiteThermal);

template <bool is_ad>
InputParameters
GraphiteThermalTempl<is_ad>::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription(
      "Calculates the thermal conductivity and the heat capacity as a function of temperature for "
      "AT 101 graphite in base SI units");
  params.addRequiredCoupledVar("temperature", "Coupled temperature variable");
  params.addParam<Real>("thermal_conductivity_scale_factor",
                        1.0,
                        "The scaling factor for graphite thermal conductivity");
  params.addParam<Real>(
      "heat_capacity_scale_factor", 1.0, "The scaling factor for graphite heat capacity");
  return params;
}

template <bool is_ad>
GraphiteThermalTempl<is_ad>::GraphiteThermalTempl(const InputParameters & parameters)
  : Material(parameters),
    _temperature(coupledValue("temperature")),
    _thermal_conductivity(declareGenericProperty<Real, is_ad>("thermal_conductivity")),
    _thermal_conductivity_dT(declareGenericProperty<Real, is_ad>("thermal_conductivity_dT")),
    _heat_capacity(declareGenericProperty<Real, is_ad>("heat_capacity")),
    _heat_capacity_dT(declareGenericProperty<Real, is_ad>("heat_capacity_dT")),
    _thermal_conductivity_scale_factor(getParam<Real>("thermal_conductivity_scale_factor")),
    _heat_capacity_scale_factor(getParam<Real>("heat_capacity_scale_factor"))
{
}

template <bool is_ad>
void
GraphiteThermalTempl<is_ad>::jacobianSetup()
{
  _check_temperature_now = false;
  int number_nonlinear_it =
      _fe_problem.getNonlinearSystemBase().getCurrentNonlinearIterationNumber();
  if (number_nonlinear_it == 0)
    _check_temperature_now = true;
}

template <bool is_ad>
void
GraphiteThermalTempl<is_ad>::computeQpProperties()
{
  // select the most conservative calibation range limits to check against:
  if (_check_temperature_now)
  {
    if (_temperature[_qp] < 495.4) // heat capacity calibration
      mooseError("The temperature in ",
                 _name,
                 " is below the calibration lower range limit at a value of ",
                 _temperature[_qp]);
    else if (_temperature[_qp] > 3312.0) // thermal conductivity calibration range
      mooseError("The temperature in ",
                 _name,
                 " is above the calibration upper range limit at a value of ",
                 _temperature[_qp]);
  }
  // Allow fall through to calculate the thermal material properties
  computeThermalConductivity();
  computeHeatCapacity();
}

template <bool is_ad>
void
GraphiteThermalTempl<is_ad>::computeThermalConductivity()
{
  _thermal_conductivity[_qp] = 1.519e-5 * Utility::pow<2>(_temperature[_qp]) -
                               8.007e-2 * _temperature[_qp] + 130.2; // in W/(m-K)
  _thermal_conductivity_dT[_qp] *= _thermal_conductivity_scale_factor;
}

template <bool is_ad>
void
GraphiteThermalTempl<is_ad>::computeHeatCapacity()
{
  Real heat_capacity, heat_capacity_dT = 0.0;
  if (_temperature[_qp] < 2004)
  {
    heat_capacity = 3.852e-7 * Utility::pow<3>(_temperature[_qp]) -
                    1.921e-3 * Utility::pow<2>(_temperature[_qp]) + 3.318 * _temperature[_qp] +
                    16.282; // in J/(K-kg)
    heat_capacity_dT = 3.852e-7 * 3.0 * Utility::pow<2>(_temperature[_qp]) -
                       1.921e-3 * 2.0 * _temperature[_qp] + 3.318;
  }
  else
  {
    heat_capacity = 5.878e-2 * _temperature[_qp] + 1931.166; // in J/(K-kg)
    heat_capacity_dT = 5.878e-2;
  }

  _heat_capacity[_qp] = heat_capacity * _heat_capacity_scale_factor;
  _heat_capacity_dT[_qp] = heat_capacity_dT * _heat_capacity_scale_factor;
}

template class GraphiteThermalTempl<false>;
template class GraphiteThermalTempl<true>;
