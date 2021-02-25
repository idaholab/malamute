#include "ThermalContactTemperatureTestFunc.h"

registerMooseObject("FreyaTestApp", ThermalContactTemperatureTestFunc);

InputParameters
ThermalContactTemperatureTestFunc::validParams()
{
  InputParameters params = Function::validParams();
  params.addClassDescription("Function used in ThermalContactCondition analytic solution testing.");
  params.addParam<Real>("graphite_electrical_conductivity",
                        73069.2,
                        "Electrical conductivity in graphite (default at 300 K).");
  params.addParam<Real>("stainless_steel_electrical_conductivity",
                        1.41867e6,
                        "Electrical conductivity in stainless steel (default at 300 K).");
  params.addParam<Real>("graphite_thermal_conductivity",
                        100.,
                        "Thermal conductivity in graphite (default at 300 K).");
  params.addParam<Real>("stainless_steel_thermal_conductivity",
                        15.,
                        "Thermal conductivity in stainless steel (default at 300 K).");
  params.addParam<Real>("electrical_contact_conductance",
                        75524.,
                        "Electrical contact conductance at the stainless-graphite interface "
                        "(default is at 300 K with 3 kN/m^2 applied pressure).");
  params.addParam<Real>("thermal_contact_conductance",
                        0.242,
                        "Thermal contact conductance at the stainless-graphite interface (default "
                        "is at 300 K with 3 kN/m^2 applied pressure).");
  MooseEnum domain("stainless_steel graphite");
  params.addParam<MooseEnum>(
      "domain", domain, "Material domain / block of interest (stainless_steel, graphite).");
  return params;
}

ThermalContactTemperatureTestFunc::ThermalContactTemperatureTestFunc(const InputParameters & parameters)
  : Function(parameters),
    _electrical_conductivity_graphite(getParam<Real>("graphite_electrical_conductivity")),
    _electrical_conductivity_stainless_steel(
        getParam<Real>("stainless_steel_electrical_conductivity")),
    _thermal_conductivity_graphite(getParam<Real>("graphite_thermal_conductivity")),
    _thermal_conductivity_stainless_steel(getParam<Real>("stainless_steel_thermal_conductivity")),
    _electrical_contact_conductance(getParam<Real>("electrical_contact_conductance")),
    _thermal_contact_conductance(getParam<Real>("thermal_contact_conductance")),
    _domain(getParam<MooseEnum>("domain"))
{
}

Real
ThermalContactTemperatureTestFunc::value(Real /*t*/, const Point & p) const
{
  return twoBlockFunction(p);
}

Real
ThermalContactTemperatureTestFunc::twoBlockFunction(const Point & p) const
{
  // Analytic potential function gradient and interface calculation
  Real denominator_potential =
      _electrical_contact_conductance * _electrical_conductivity_stainless_steel +
      _electrical_conductivity_graphite * _electrical_conductivity_stainless_steel +
      _electrical_conductivity_graphite * _electrical_contact_conductance;

  Real graphite_gradient = -_electrical_contact_conductance *
                           _electrical_conductivity_stainless_steel / denominator_potential;
  Real stainless_steel_gradient =
      -_electrical_contact_conductance * _electrical_conductivity_graphite / denominator_potential;

  Real graphite_func_interface = graphite_gradient * (1. - 2.);

  Real stainless_steel_func_interface = stainless_steel_gradient + 1.;

  // Analytic Temperature Function

  Real q_elec = 0.5 * _electrical_contact_conductance *
                std::pow((stainless_steel_func_interface - graphite_func_interface), 2.);

  Real a_SS = -_electrical_conductivity_stainless_steel /
              (2 * _thermal_conductivity_stainless_steel) * std::pow(stainless_steel_gradient, 2.);

  Real a_G = -_electrical_conductivity_graphite / (2. * _thermal_conductivity_graphite) *
             std::pow(graphite_gradient, 2.);

  Real h_SS = 2. * _thermal_conductivity_stainless_steel * a_SS +
              _thermal_contact_conductance * a_SS + 3. * _thermal_contact_conductance * a_G -
              q_elec;

  Real h_G = 2. * _thermal_conductivity_graphite * a_G + _thermal_contact_conductance * a_SS +
             3. * _thermal_contact_conductance * a_G + q_elec;

  Real denominator_thermal =
      (_thermal_conductivity_stainless_steel + _thermal_contact_conductance) *
          (_thermal_conductivity_graphite + _thermal_contact_conductance) -
      std::pow(_thermal_contact_conductance, 2.);

  Real b_SS = (_thermal_contact_conductance * h_G -
               (_thermal_conductivity_graphite + _thermal_contact_conductance) * h_SS) /
              denominator_thermal;

  Real b_G = (_thermal_contact_conductance * h_SS -
              (_thermal_conductivity_stainless_steel + _thermal_contact_conductance) * h_G) /
             denominator_thermal;

  Real d_SS = 300.;

  Real d_G = 300. - 4. * a_G - 2. * b_G;

  if (_domain == STAINLESS_STEEL)
  {
    return a_SS * p(0) * p(0) + b_SS * p(0) + d_SS;
  }
  else if (_domain == GRAPHITE)
  {
    return a_G * p(0) * p(0) + b_G * p(0) + d_G;
  }
  else
  {
    mooseError(_name + ": Error in selecting proper domain in ThermalContactTemperatureTestFunc.");
  }
}
