#include "ThermalContactCondition.h"

// MOOSE includes
#include "Assembly.h"

registerMooseObject("FreyaApp", ThermalContactCondition);

InputParameters
ThermalContactCondition::validParams()
{
  InputParameters params = InterfaceKernel::validParams();
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
  : InterfaceKernel(parameters),
    _thermal_contact_conductance(getParam<Real>("thermal_contact_conductance")),
    _electrical_contact_conductance(getParam<Real>("electrical_contact_conductance")),
    _potential_master(coupledValue("master_potential")),
    _potential_neighbor(coupledValue("neighbor_potential")),
    _potential_master_id(coupled("master_potential")),
    _potential_master_var(*getVar("master_potential", 0)),
    _potential_master_phi(_assembly.phiFace(_potential_master_var)),
    _potential_neighbor_id(coupled("neighbor_potential")),
    _potential_neighbor_var(*getVar("neighbor_potential", 0)),
    _potential_neighbor_phi(_assembly.phiFaceNeighbor(_potential_neighbor_var)),
    _splitting_factor(getParam<Real>("splitting_factor"))
{
}

Real
ThermalContactCondition::computeQpResidual(Moose::DGResidualType type)
{
  Real q_electric = _electrical_contact_conductance *
                    std::pow((_potential_master[_qp] - _potential_neighbor[_qp]), 2);

  Real q_temperature = _thermal_contact_conductance * (_u[_qp] - _neighbor_value[_qp]);

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

Real
ThermalContactCondition::computeQpJacobian(Moose::DGJacobianType type)
{
  switch (type)
  {
    // element residual statement, element (master) temperature variable is variable of differentiation
    case Moose::ElementElement:
      return _thermal_contact_conductance * _phi[_j][_qp] * _test[_i][_qp];

    // neighbor residual statement, neighbor temperature variable is variable of differentiation
    case Moose::NeighborNeighbor:
      return _thermal_contact_conductance * _phi_neighbor[_j][_qp] * _test_neighbor[_i][_qp];

    // neighbor residual statement, element (master) temperature variable is variable of differentiation
    case Moose::NeighborElement:
      return _thermal_contact_conductance * -_phi[_j][_qp] * _test_neighbor[_i][_qp];

    // element residual statement, neighbor temperature variable is variable of differentiation
    case Moose::ElementNeighbor:
      return _thermal_contact_conductance * -_phi_neighbor[_j][_qp] * _test[_i][_qp];

    default:
      return 0.0;
  }
}

Real
ThermalContactCondition::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
{
  switch (type)
  {
    // element residual statement, element (master) potential variable is variable of differentiation
    case Moose::ElementElement:
      if (jvar == _potential_master_id)
        return -2 * _splitting_factor * _electrical_contact_conductance *
               (_potential_master[_qp] - _potential_neighbor[_qp]) *
               _potential_master_phi[_j][_qp] * _test[_i][_qp];
      else
        return 0.0;

    // neighbor residual statement, neighbor potential variable is variable of differentiation
    case Moose::NeighborNeighbor:
      if (jvar == _potential_neighbor_id)
        return -2 * (1 - _splitting_factor) * _electrical_contact_conductance *
               (_potential_master[_qp] - _potential_neighbor[_qp]) *
               -_potential_neighbor_phi[_j][_qp] * _test_neighbor[_i][_qp];
      else
        return 0.0;

    // neighbor residual statement, element (master) potential variable is variable of differentiation
    case Moose::NeighborElement:
      if (jvar == _potential_master_id)
        return -2 * (1 - _splitting_factor) * _electrical_contact_conductance *
               (_potential_master[_qp] - _potential_neighbor[_qp]) *
               _potential_master_phi[_j][_qp] * _test_neighbor[_i][_qp];
      else
        return 0.0;

    // element residual statement, neighbor potential variable is variable of differentiation
    case Moose::ElementNeighbor:
      if (jvar == _potential_neighbor_id)
        return -2 * _splitting_factor * _electrical_contact_conductance *
               (_potential_master[_qp] - _potential_neighbor[_qp]) *
               -_potential_neighbor_phi[_j][_qp] * _test[_i][_qp];
      else
        return 0.0;

    default:
      return 0.0;
  }
}
