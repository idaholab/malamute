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

  /// Thermal conductivity property for the primary side
  const MaterialProperty<Real> & _thermal_conductivity_primary;

  /// Thermal conductivity property for the secondary side
  const MaterialProperty<Real> & _thermal_conductivity_secondary;

  /// Electrical conductivity property for the primary side
  const MaterialProperty<Real> & _electrical_conductivity_primary;

  /// Electrical conductivity property for the secondary side
  const MaterialProperty<Real> & _electrical_conductivity_secondary;

  /// User-provided thermal contact conductance coefficient (indicates ability to conduct heat across interface)
  const Real & _user_thermal_contact_conductance;

  /// User-provided electrical contact conductance coefficient (indicates ability to conduct heat as a result of electrostatic joule heating across interface)
  const Real & _user_electrical_contact_conductance;

  /// The electrostatic potential value associated with the primary side of the interface
  const ADVariableValue & _potential_primary;

  /// The electrostatic potential value associated with the secondary side of the interface
  const ADVariableValue & _potential_secondary;

  /// Splitting factor for joule heating source between primary and secondary sides
  const Real & _splitting_factor;

  /// Geometric mean of the hardness from both sides of the boundary, taken in as a material property
  const ADMaterialProperty<Real> & _mean_hardness;

  /// Mechanical pressure uniformly applied at the contact surface area (user-supplied for now)
  const Real & _mechanical_pressure;

  /// Experimental proportional fit parameter for thermal contact conductance parameter (set using Cincotti et al DOI:10.1002/aic.11102)
  const Real _alpha_thermal;

  /// Experimental power fit parameter for thermal contact conductance parameter (set using Cincotti et al DOI:10.1002/aic.11102)
  const Real _beta_thermal;

  /// Experimental proportional fit parameter for electrical contact conductance parameter (set using Cincotti et al DOI:10.1002/aic.11102)
  const Real _alpha_electric;

  /// Experimental power fit parameter for electrical contact conductance parameter (set using Cincotti et al DOI:10.1002/aic.11102)
  const Real _beta_electric;

  /// Check parameter for user-provided electrical contact conductance value
  bool _electrical_conductance_was_set;

  /// Check parameter for user-provided thermal contact conductance value
  bool _thermal_conductance_was_set;

  /// Check parameter for material-provided mean hardness value
  bool _mean_hardness_was_set;
};
