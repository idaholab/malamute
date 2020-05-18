/*************************************************/
/*           Will be part of Freya App           */
/*************************************************/

#pragma once

#include "IntegratedBC.h"

/**
 * Boundary condition for convective heat flux where temperature and heat transfer coefficient are
 * given by auxiliary variables.  Typically used in multi-app coupling scenario. It is possible to
 * couple in a vector variable where each entry corresponds to a "phase".
 */
class CoupledSimpleRadiativeHeatFluxBC : public IntegratedBC
{
public:
  static InputParameters validParams();

  CoupledSimpleRadiativeHeatFluxBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();

  /// The number of components/ phases within the body which loses heat
  unsigned int _n_components;

  /// Far-field temperatue fields for each component phase
  std::vector<const VariableValue *> _T_infinity;

  /// Surface emissivity constant for each component phase
  std::vector<Real> _emissivity;

  /// Volume fraction of individual phase
  std::vector<const VariableValue *> _alpha;

  /// Stefan-Boltzmann constant
  const Real _sigma;
};
