#include "ThermalContactCondition.h"

registerMooseObject("FreyaApp", ThermalContactCondition);

InputParameters
ThermalContactCondition::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addRequiredParam<Real>("thermal_contact_conductance",
                                "Thermal contact conductance coefficient.");
  params.addRequiredParam<Real>("electrical_contact_conductance",
                                "Electrical contact conductance coefficient.");
  params.addRequiredCoupledVar("master_potential", "Electrostatic potential on the master block.");
  params.addRequiredCoupledVar("neighbor_potential",
                               "Electrostatic potential on the neighbor block.");
  params.addParam<Real>("splitting_factor", 0.5, "Splitting factor of the Joule heating source.");
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
    _thermal_contact_conductance(getParam<Real>("thermal_contact_conductance")),
    _electrical_contact_conductance(getParam<Real>("electrical_contact_conductance")),
    _potential_master(adCoupledValue("master_potential")),
    _potential_neighbor(adCoupledValue("neighbor_potential")),
    _splitting_factor(getParam<Real>("splitting_factor"))
{
}

ADReal
ThermalContactCondition::computeQpResidual(Moose::DGResidualType type)
{
  ADReal q_electric = _electrical_contact_conductance *
                      std::pow((_potential_master[_qp] - _potential_neighbor[_qp]), 2);

  ADReal q_temperature = _thermal_contact_conductance * (_u[_qp] - _neighbor_value[_qp]);

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
