/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2022, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "LevelSetHeavisideFunction.h"

registerMooseObject("MalamuteApp", LevelSetHeavisideFunction);

InputParameters
LevelSetHeavisideFunction::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("Computes Heaviside function given by a level set.");
  params.addRequiredCoupledVar("level_set", "Level set variable");
  return params;
}

LevelSetHeavisideFunction::LevelSetHeavisideFunction(const InputParameters & parameters)
  : ADMaterial(parameters),
    _c(adCoupledValue("level_set")),
    _heaviside_function(declareADProperty<Real>("heaviside_function"))
{
}

void
LevelSetHeavisideFunction::computeQpProperties()
{
  _heaviside_function[_qp] = _c[_qp];
}
