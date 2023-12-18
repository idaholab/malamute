/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADMaterial.h"

/**
 *  This material object calculates the harmonic mean of the hardness values for
 *  AT 101 graphite and AISI 304 stainless steel, as obtained from
 *  Cincotti et al, AIChE Journal 53, 2007.
 */
class GraphiteStainlessMeanHardness : public ADMaterial
{
public:
  static InputParameters validParams();

  GraphiteStainlessMeanHardness(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  /// Hardness value of AT 101 grahite in Pa
  const Real _graphite_hardness;

  /// Hardness value of AISI 304 stainless steel in Pa
  const Real _stainless_steel_hardness;

  /// Material property value of the harmonic mean of graphite and stainless steel hardness
  ADMaterialProperty<Real> & _mean_hardness;
};
