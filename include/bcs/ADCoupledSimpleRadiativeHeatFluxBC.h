/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*               Copyright 2021, Battelle Energy Alliance, LLC              */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADIntegratedBC.h"

/**
 * Boundary condition for convective heat flux where temperature and heat transfer coefficient are
 * given by auxiliary variables.  Typically used in a multi-app coupling scenario. It is possible to
 * couple in a vector variable where each entry corresponds to a "phase".
 */
class ADCoupledSimpleRadiativeHeatFluxBC : public ADIntegratedBC
{
public:
  static InputParameters validParams();

  ADCoupledSimpleRadiativeHeatFluxBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual();

  /// The number of components / phases within the body which loses heat
  unsigned int _n_components;

  /// Far-field temperature fields for each component phase
  std::vector<const VariableValue *> _T_infinity;

  /// Surface emissivity constant for each component phase
  const std::vector<Real> & _emissivity;

  /// Volume fraction of individual phase
  std::vector<const VariableValue *> _alpha;

  /// Stefan-Boltzmann constant
  const Real _sigma;
};
