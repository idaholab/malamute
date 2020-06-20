#pragma once

#include "ADInterfaceKernel.h"

/**
 * This interfacekernel implements the thermal contact conductance across a
 * boundary formed between two dissimilar materials (resulting in a temperature
 * discontinuity) under the influence of an electrostatic potential.
 */

class ThermalContactCondition : public ADInterfaceKernel
{
public:
  static InputParameters validParams();

  ThermalContactCondition(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual(Moose::DGResidualType type) override;

  /// Thermal contact conductance coefficient (indicates ability to conduct heat across interface)
  const Real & _thermal_contact_conductance;

  /// Electrical contact conductance coefficient (indicates ability to conduct heat as a result of electrostatic joule heating across interface)
  const Real & _electrical_contact_conductance;

  /// The electrostatic potential value associated with the master side of the interface
  const ADVariableValue & _potential_master;

  /// The electrostatic potential value associated with the neighbor side of the interface
  const ADVariableValue & _potential_neighbor;

  /// Splitting factor for joule heating source between master and neighbor sides
  const Real & _splitting_factor;
};
