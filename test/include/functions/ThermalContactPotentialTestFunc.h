#pragma once

#include "Function.h"

/**
 *  Analytical solution function to test the ThermalContactCondition
 *  interface kernel. Constants are taken from the materials (graphite and
 *  stainless steel) used within the test. Defaults are taken at 300 K.
 */
class ThermalContactPotentialTestFunc : public Function
{
public:
  static InputParameters validParams();

  ThermalContactPotentialTestFunc(const InputParameters & parameters);

  virtual Real value(Real t, const Point & p) const override;

protected:

  /// Function used to calculate two block test case analytic solution
  Real twoBlockFunction(const Point & p) const;

  /// Electrical conductivity property for graphite
  const Real & _electrical_conductivity_graphite;

  /// Electrical conductivity property for stainless steel
  const Real & _electrical_conductivity_stainless_steel;

  /// Contact conductance property for the tested interface
  const Real & _electrical_contact_conductance;

  /**
   *  MooseEnum to determine which part of the analytic solution
   *  needs to be enabled (Stainless Steel vs. Graphite)
   */
  const MooseEnum & _domain;

private:
  /**
   * Enum used in comparisons with _domain. Enum-to-enum comparisons are a bit
   * more lightweight, so we should create another enum with the possible choices.
   */
  enum DomainEnum
  {
    STAINLESS_STEEL,
    GRAPHITE
  };
};
