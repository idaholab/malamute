#pragma once

#include "InterfaceKernel.h"

class ThermalContactConductance : public InterfaceKernel
{
public:
  static InputParameters validParams();

  ThermalContactConductance(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual(Moose::DGResidualType type) override;
  virtual Real computeQpJacobian(Moose::DGJacobianType type) override;
  virtual Real computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar) override;

  const Real & _htc;
  const Real & _electrical_contact_resistance;
  const VariableValue & _potential_master;
  const VariableValue & _potential_neighbor;

  // For computeQpOffDiagJacobian
  unsigned int _potential_master_id;
  MooseVariable & _potential_master_var;
  const VariablePhiValue & _potential_master_phi;
  unsigned int _potential_neighbor_id;
  MooseVariable &  _potential_neighbor_var;
  const VariablePhiValue & _potential_neighbor_phi;
};
