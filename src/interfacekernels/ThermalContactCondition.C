#include "ThermalContactCondition.h"

registerMooseObject("FreyaApp", ThermalContactCondition);

InputParameters
ThermalContactCondition::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addParam<MaterialPropertyName>("master_thermal_conductivity",
                                        "thermal_conductivity",
                                        "Thermal conductivity on the master block.");
  params.addParam<MaterialPropertyName>("neighbor_thermal_conductivity",
                                        "thermal_conductivity",
                                        "Thermal conductivity on the neighbor block.");
  params.addParam<MaterialPropertyName>("master_electrical_conductivity",
                                        "electrical_conductivity",
                                        "Electrical conductivity on the master block.");
  params.addParam<MaterialPropertyName>("neighbor_electrical_conductivity",
                                        "electrical_conductivity",
                                        "Electrical conductivity on the neighbor block.");
  params.addParam<Real>("user_thermal_contact_conductance",
                        "User-provided thermal contact conductance coefficient.");
  params.addParam<Real>("user_electrical_contact_conductance",
                        "User-provided electrical contact conductance coefficient.");
  params.addRequiredCoupledVar("master_potential", "Electrostatic potential on the master block.");
  params.addRequiredCoupledVar("neighbor_potential",
                               "Electrostatic potential on the neighbor block.");
  params.addParam<Real>("splitting_factor", 0.5, "Splitting factor of the Joule heating source.");
  params.addParam<MaterialPropertyName>(
      "mean_hardness",
      "mean_hardness",
      "Geometric mean of the hardness of each contacting material.");
  params.addParam<Real>("mechanical_pressure",
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
    _thermal_conductivity_master(getMaterialProperty<Real>("master_thermal_conductivity")),
    _thermal_conductivity_neighbor(
        getNeighborMaterialProperty<Real>("neighbor_thermal_conductivity")),
    _electrical_conductivity_master(getMaterialProperty<Real>("master_electrical_conductivity")),
    _electrical_conductivity_neighbor(
        getNeighborMaterialProperty<Real>("neighbor_electrical_conductivity")),
    _user_thermal_contact_conductance(isParamValid("user_thermal_contact_conductance")
                                          ? getParam<Real>("user_thermal_contact_conductance")
                                          : _real_zero),
    _user_electrical_contact_conductance(isParamValid("user_electrical_contact_conductance")
                                             ? getParam<Real>("user_electrical_contact_conductance")
                                             : _real_zero),
    _potential_master(adCoupledValue("master_potential")),
    _potential_neighbor(adCoupledValue("neighbor_potential")),
    _splitting_factor(getParam<Real>("splitting_factor")),
    _mean_hardness(isParamValid("user_thermal_contact_conductance")
                       ? getGenericZeroMaterialProperty<Real, true>("mean_hardness")
                       : isParamValid("user_electrical_contact_conductance")
                             ? getGenericZeroMaterialProperty<Real, true>("mean_hardness")
                             : getADMaterialProperty<Real>("mean_hardness")),
    _mechanical_pressure(isParamValid("mechanical_pressure") ? getParam<Real>("mechanical_pressure")
                                                             : _real_zero),
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

  ADReal mean_thermal_conductivity =
      2 * _thermal_conductivity_master[_qp] * _thermal_conductivity_neighbor[_qp] /
      (_thermal_conductivity_master[_qp] + _thermal_conductivity_neighbor[_qp]);

  ADReal mean_electrical_conductivity =
      2 * _electrical_conductivity_master[_qp] * _electrical_conductivity_neighbor[_qp] /
      (_electrical_conductivity_master[_qp] + _electrical_conductivity_neighbor[_qp]);

  if (_electrical_conductance_was_set && _thermal_conductance_was_set && !_mean_hardness_was_set)
  {
    thermal_contact_conductance = _user_thermal_contact_conductance;
    electrical_contact_conductance = _user_electrical_contact_conductance;
  }
  else if (_mean_hardness_was_set && !_thermal_conductance_was_set &&
           !_electrical_conductance_was_set)
  {
    thermal_contact_conductance =
        _alpha_thermal * mean_thermal_conductivity *
        std::pow((_mechanical_pressure / _mean_hardness[_qp]), _beta_thermal);

    electrical_contact_conductance =
        _alpha_electric * mean_electrical_conductivity *
        std::pow((_mechanical_pressure / _mean_hardness[_qp]), _beta_electric);
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

  ADReal potential_diff = _potential_master[_qp] - _potential_neighbor[_qp];

  ADReal q_electric = electrical_contact_conductance * potential_diff * potential_diff;

  ADReal q_temperature = thermal_contact_conductance * (_u[_qp] - _neighbor_value[_qp]);

  switch (type)
  {
    case Moose::Element:
      return (q_temperature - _splitting_factor * q_electric) * _test[_i][_qp];

    case Moose::Neighbor:
      return -(q_temperature + (1 - _splitting_factor) * q_electric) * _test_neighbor[_i][_qp];

    default:
      return 0.0;
  }
}
