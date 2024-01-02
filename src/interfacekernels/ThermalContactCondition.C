/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "ThermalContactCondition.h"

registerMooseObject("MalamuteApp", ThermalContactCondition);

InputParameters
ThermalContactCondition::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addParam<MaterialPropertyName>("primary_thermal_conductivity",
                                        "thermal_conductivity",
                                        "Thermal conductivity on the primary block.");
  params.addParam<MaterialPropertyName>("secondary_thermal_conductivity",
                                        "thermal_conductivity",
                                        "Thermal conductivity on the secondary block.");
  params.addParam<MaterialPropertyName>("primary_electrical_conductivity",
                                        "electrical_conductivity",
                                        "Electrical conductivity on the primary block.");
  params.addParam<MaterialPropertyName>("secondary_electrical_conductivity",
                                        "electrical_conductivity",
                                        "Electrical conductivity on the secondary block.");
  params.addParam<FunctionName>("user_thermal_contact_conductance",
                                0.0,
                                "User-provided thermal contact conductance coefficient.");
  params.addParam<FunctionName>("user_electrical_contact_conductance",
                                0.0,
                                "User-provided electrical contact conductance coefficient.");
  params.addRequiredCoupledVar("primary_potential",
                               "Electrostatic potential on the primary block.");
  params.addRequiredCoupledVar("secondary_potential",
                               "Electrostatic potential on the secondary block.");
  params.addParam<Real>("splitting_factor", 0.5, "Splitting factor of the Joule heating source.");
  params.addParam<MaterialPropertyName>(
      "mean_hardness",
      "mean_hardness",
      "Geometric mean of the hardness of each contacting material.");
  params.addParam<FunctionName>("mechanical_pressure",
                                0.0,
                                "Mechanical pressure uniformly applied at the contact surface area "
                                "(Pressure = Force / Surface Area).");
  params.addClassDescription(
      "Interface condition that describes the thermal contact resistance across a boundary formed "
      "between two dissimilar materials (resulting in a temperature discontinuity) under the "
      "influence of an electrostatic potential, as described in Cincotti, et al (DOI: "
      "10.1002/aic.11102). Thermal conductivity on each side of the boundary is defined via the "
      "material properties system.");
  return params;
}

ThermalContactCondition::ThermalContactCondition(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _thermal_conductivity_primary(getADMaterialProperty<Real>("primary_thermal_conductivity")),
    _thermal_conductivity_secondary(
        getNeighborADMaterialProperty<Real>("secondary_thermal_conductivity")),
    _electrical_conductivity_primary(
        getADMaterialProperty<Real>("primary_electrical_conductivity")),
    _electrical_conductivity_secondary(
        getNeighborADMaterialProperty<Real>("secondary_electrical_conductivity")),
    _user_thermal_contact_conductance(getFunction("user_thermal_contact_conductance")),
    _user_electrical_contact_conductance(getFunction("user_electrical_contact_conductance")),
    _potential_primary(adCoupledValue("primary_potential")),
    _secondary_potential_var(getVar("secondary_potential", 0)),
    _potential_secondary(_secondary_potential_var->adSlnNeighbor()),
    _splitting_factor(getParam<Real>("splitting_factor")),
    _mean_hardness(isParamValid("user_thermal_contact_conductance")
                       ? getGenericZeroMaterialProperty<Real, true>("mean_hardness")
                   : isParamValid("user_electrical_contact_conductance")
                       ? getGenericZeroMaterialProperty<Real, true>("mean_hardness")
                       : getADMaterialProperty<Real>("mean_hardness")),
    _mechanical_pressure(getFunction("mechanical_pressure")),
    _alpha_thermal(22810.0),
    _beta_thermal(1.08),
    _alpha_electric(64.0),
    _beta_electric(0.35)
{
  _electrical_conductance_was_set =
      parameters.isParamSetByUser("user_electrical_contact_conductance");
  _thermal_conductance_was_set = parameters.isParamSetByUser("user_thermal_contact_conductance");
  _mean_hardness_was_set = parameters.isParamSetByUser("mean_hardness");
}

ADReal
ThermalContactCondition::computeQpResidual(Moose::DGResidualType type)
{
  ADReal thermal_contact_conductance = 0.0;
  ADReal electrical_contact_conductance = 0.0;

  if (_electrical_conductance_was_set && _thermal_conductance_was_set && !_mean_hardness_was_set)
  {
    thermal_contact_conductance = _user_thermal_contact_conductance.value(_t, _q_point[_qp]);
    electrical_contact_conductance = _user_electrical_contact_conductance.value(_t, _q_point[_qp]);
  }
  else if (_mean_hardness_was_set && !_thermal_conductance_was_set &&
           !_electrical_conductance_was_set)
  {
    ADReal mean_thermal_conductivity =
        2 * _thermal_conductivity_primary[_qp] * _thermal_conductivity_secondary[_qp] /
        (_thermal_conductivity_primary[_qp] + _thermal_conductivity_secondary[_qp]);

    ADReal mean_electrical_conductivity =
        2 * _electrical_conductivity_primary[_qp] * _electrical_conductivity_secondary[_qp] /
        (_electrical_conductivity_primary[_qp] + _electrical_conductivity_secondary[_qp]);

    thermal_contact_conductance =
        _alpha_thermal * mean_thermal_conductivity *
        std::pow((_mechanical_pressure.value(_t, _q_point[_qp]) / _mean_hardness[_qp]),
                 _beta_thermal);

    electrical_contact_conductance =
        _alpha_electric * mean_electrical_conductivity *
        std::pow((_mechanical_pressure.value(_t, _q_point[_qp]) / _mean_hardness[_qp]),
                 _beta_electric);
  }
  else
  {
    mooseError(
        "In ",
        _name,
        ", both user-supplied thermal/electrical conductances and mean hardness values (for "
        "calculating contact conductances) have been provided. Please only provide one or the "
        "other!");
  }

  ADReal potential_diff = _potential_primary[_qp] - _potential_secondary[_qp];

  ADReal q_electric_primary =
      _splitting_factor * electrical_contact_conductance * potential_diff * potential_diff;

  ADReal q_electric_secondary =
      (1 - _splitting_factor) * electrical_contact_conductance * potential_diff * potential_diff;

  ADReal q_temperature = thermal_contact_conductance * (_u[_qp] - _neighbor_value[_qp]);

  ADReal res = 0.0;

  switch (type)
  {
    case Moose::Element:
      res = (q_temperature - q_electric_primary) * _test[_i][_qp];
      break;

    case Moose::Neighbor:
      res = -(q_temperature + q_electric_secondary) * _test_neighbor[_i][_qp];
      break;
  }

  return res;
}
