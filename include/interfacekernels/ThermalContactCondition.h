#pragma once

#include "InterfaceKernel.h"

/**
 * This interfacekernel implements the thermal contact conductance across a
 * boundary formed between two dissimilar materials (resulting in a temperature
 * discontinuity) under the influence of an electrostatic potential.
 */

class ThermalContactCondition : public InterfaceKernel
{
public:
  static InputParameters validParams();

  ThermalContactCondition(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual(Moose::DGResidualType type) override;
  virtual Real computeQpJacobian(Moose::DGJacobianType type) override;
  virtual Real computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar) override;

  /// Thermal contact conductance coefficient (indicates ability to conduct heat across interface)
  const Real & _thermal_contact_conductance;

  /// Electrical contact conductance coefficient (indicates ability to conduct heat as a result of electrostatic joule heating across interface)
  const Real & _electrical_contact_conductance;

  /// The electrostatic potential value associated with the master side of the interface
  const VariableValue & _potential_master;

  /// The electrostatic potential value associated with the neighbor side of the interface
  const VariableValue & _potential_neighbor;

  /// Variable ID for the master electrostatic potential variable
  unsigned int _potential_master_id;

  /// Master electrostatic potential variable
  MooseVariable & _potential_master_var;

  /// Master electrostatic potential variable basis function
  const VariablePhiValue & _potential_master_phi;

  /// Variable ID for the neighbor electrostatic potential variable
  unsigned int _potential_neighbor_id;

  /// Neighbor electrostatic potential variable
  MooseVariable &  _potential_neighbor_var;

  /// Neighbor electrostatic potential variable basis function
  const VariablePhiValue & _potential_neighbor_phi;

  /// Splitting factor for joule heating source between master and neighbor sides
  const Real & _splitting_factor;
};
