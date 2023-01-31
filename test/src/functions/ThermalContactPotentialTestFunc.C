/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "ThermalContactPotentialTestFunc.h"

registerMooseObject("MalamuteTestApp", ThermalContactPotentialTestFunc);

InputParameters
ThermalContactPotentialTestFunc::validParams()
{
  InputParameters params = Function::validParams();
  params.addClassDescription("Function used in ThermalContactCondition analytic solution testing.");
  params.addParam<Real>(
      "graphite_conductivity",
      73069.2,
      "Conductivity in graphite (from Cincotti et al DOI:10.1002/aic.11102, default at 300 K).");
  params.addParam<Real>("stainless_steel_conductivity",
                        1.41867e6,
                        "Conductivity in stainless steel (from Cincotti et al "
                        "DOI:10.1002/aic.11102, default at 300 K).");
  params.addParam<Real>(
      "contact_conductance",
      75524.,
      "Electrical contact conductance at the interface (from Cincotti et al "
      "DOI:10.1002/aic.11102, default is at 300 K with 3 kN/m^2 applied pressure).");
  MooseEnum domain("stainless_steel graphite");
  params.addParam<MooseEnum>(
      "domain", domain, "Material domain / block of interest (stainless_steel, graphite).");
  return params;
}

ThermalContactPotentialTestFunc::ThermalContactPotentialTestFunc(const InputParameters & parameters)
  : Function(parameters),
    _electrical_conductivity_graphite(getParam<Real>("graphite_conductivity")),
    _electrical_conductivity_stainless_steel(getParam<Real>("stainless_steel_conductivity")),
    _electrical_contact_conductance(getParam<Real>("contact_conductance")),
    _domain(getParam<MooseEnum>("domain"))
{
}

Real
ThermalContactPotentialTestFunc::value(Real /*t*/, const Point & p) const
{
  return twoBlockFunction(p);
}

Real
ThermalContactPotentialTestFunc::twoBlockFunction(const Point & p) const
{
  Real denominator = _electrical_contact_conductance * _electrical_conductivity_stainless_steel +
                     _electrical_conductivity_graphite * _electrical_conductivity_stainless_steel +
                     _electrical_conductivity_graphite * _electrical_contact_conductance;

  Real graphite_coefficient =
      -_electrical_contact_conductance * _electrical_conductivity_stainless_steel / denominator;

  Real stainless_steel_coefficient =
      -_electrical_contact_conductance * _electrical_conductivity_graphite / denominator;

  Real graphite_func = graphite_coefficient * (p(0) - 2);

  Real stainless_steel_func = stainless_steel_coefficient * p(0) + 1;

  if (_domain == DomainEnum::STAINLESS_STEEL)
  {
    return stainless_steel_func;
  }
  else if (_domain == DomainEnum::GRAPHITE)
  {
    return graphite_func;
  }
  else
  {
    mooseError(_name + ": Error in selecting proper domain in ThermalContactPotentialTestFunc.");
  }
}
