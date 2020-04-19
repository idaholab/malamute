#include "ThermalContactConductance.h"

// MOOSE includes
#include "Assembly.h"

registerMooseObject("FreyaApp", ThermalContactConductance);

InputParameters
ThermalContactConductance::validParams()
{
  InputParameters params = InterfaceKernel::validParams();
  params.addRequiredParam<Real>("thermal_contact_conductance",
                                "Thermal contact conductance coefficient.");
  params.addRequiredParam<Real>("electrical_contact_conductance",
                                "Electrical contact conductance coefficient.");
  params.addRequiredCoupledVar("master_potential", "Electrostatic potential on the master block.");
  params.addRequiredCoupledVar("neighbor_potential",
                               "Electrostatic potential on the neighbor block.");
  params.addClassDescription(
      "Interface condition that describes the thermal contact resistance across a boundary formed "
      "between two dissimilar materials (resulting in a temperature discontinuity) under the "
      "influence of an electrostatic potential, as described in Cincotti, et al (DOI: "
      "10.1002/aic.11102). Thermal conductivity on each side of the boundary is defined via the "
      "material properties system.");
  return params;
}

ThermalContactConductance::ThermalContactConductance(const InputParameters & parameters)
  : InterfaceKernel(parameters),
    _htc(getParam<Real>("htc")),
    _electrical_contact_resistance(getParam<Real>("electrical_contact_resistance")),
    _potential_master(coupledValue("master_potential")),
    _potential_neighbor(coupledValue("neighbor_potential")),
    _potential_master_id(coupled("master_potential")),
    _potential_master_var(*getVar("master_potential", 0)),
    _potential_master_phi(_assembly.phiFace(_potential_master_var)),
    _potential_neighbor_id(coupled("neighbor_potential")),
    _potential_neighbor_var(*getVar("neighbor_potential", 0)),
    _potential_neighbor_phi(_assembly.phiFaceNeighbor(_potential_neighbor_var))
{
}

Real
ThermalContactConductance::computeQpResidual(Moose::DGResidualType type)
{
  Real q_electric = 0.5 * _electrical_contact_resistance *
                    (_potential_master[_qp] - _potential_neighbor[_qp]) *
                    (_potential_master[_qp] - _potential_neighbor[_qp]);

  Real q_temperature = _htc * (_u[_qp] - _neighbor_value[_qp]);

  switch (type)
  {
    case Moose::Element:
      return (q_temperature - q_electric) * _test[_i][_qp];

    case Moose::Neighbor:
      return -(q_temperature + q_electric) * _test_neighbor[_i][_qp];

    default:
      return 0.0;
  }
}

Real
ThermalContactConductance::computeQpJacobian(Moose::DGJacobianType type)
{
  switch (type)
  {
    case Moose::ElementElement:
      return _htc * _phi[_j][_qp] * _test[_i][_qp];

    case Moose::NeighborNeighbor:
      return _htc * _phi_neighbor[_j][_qp] * _test_neighbor[_i][_qp];

    case Moose::NeighborElement:
      return _htc * -_phi[_j][_qp] * _test_neighbor[_i][_qp];

    case Moose::ElementNeighbor:
      return _htc * -_phi_neighbor[_j][_qp] * _test[_i][_qp];

    default:
      return 0.0;
  }
}

Real
ThermalContactConductance::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
{
  switch (type)
  {
    case Moose::ElementElement:
      if (jvar == _potential_master_id)
        return -_electrical_contact_resistance *
               (_potential_master[_qp] - _potential_neighbor[_qp]) *
               _potential_master_phi[_j][_qp] * _test[_i][_qp];
      else
        return 0.0;

    case Moose::NeighborNeighbor:
      if (jvar == _potential_neighbor_id)
        return -_electrical_contact_resistance *
               (_potential_master[_qp] - _potential_neighbor[_qp]) *
               -_potential_neighbor_phi[_j][_qp] * _test_neighbor[_i][_qp];
      else
        return 0.0;

    case Moose::NeighborElement:
      if (jvar == _potential_master_id)
        return -_electrical_contact_resistance *
               (_potential_master[_qp] - _potential_neighbor[_qp]) *
               _potential_master_phi[_j][_qp] * _test_neighbor[_i][_qp];
      else
        return 0.0;

    case Moose::ElementNeighbor:
      if (jvar == _potential_neighbor_id)
        return -_electrical_contact_resistance *
               (_potential_master[_qp] - _potential_neighbor[_qp]) *
               -_potential_neighbor_phi[_j][_qp] * _test[_i][_qp];
      else
        return 0.0;

    default:
      return 0.0;
  }
}
