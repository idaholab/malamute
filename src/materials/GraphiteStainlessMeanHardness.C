/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2022, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "GraphiteStainlessMeanHardness.h"

registerMooseObject("MalamuteApp", GraphiteStainlessMeanHardness);

InputParameters
GraphiteStainlessMeanHardness::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription(
      "Calculates the harmonic mean of the hardness values of graphite and stainless steel.");
  return params;
}

GraphiteStainlessMeanHardness::GraphiteStainlessMeanHardness(const InputParameters & parameters)
  : Material(parameters),
    _graphite_hardness(3.5e9),
    _stainless_steel_hardness(1.92e9),
    _mean_hardness(declareADProperty<Real>("graphite_stainless_mean_hardness"))
{
}

void
GraphiteStainlessMeanHardness::computeQpProperties()
{
  _mean_hardness[_qp] = 2. * _graphite_hardness * _stainless_steel_hardness /
                        (_graphite_hardness + _stainless_steel_hardness);
}
