/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2022, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "LevelSetDeltaFunction.h"

registerMooseObject("MalamuteApp", LevelSetDeltaFunction);

InputParameters
LevelSetDeltaFunction::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("Computes delta function given by a level set.");
  params.addRequiredCoupledVar("level_set_gradient",
                               "Regularized gradient of the level set variable");
  return params;
}

LevelSetDeltaFunction::LevelSetDeltaFunction(const InputParameters & parameters)
  : ADMaterial(parameters),
    _grad_c(adCoupledVectorValue("level_set_gradient")),
    _delta_function(declareADProperty<Real>("delta_function"))
{
}

void
LevelSetDeltaFunction::computeQpProperties()
{
  _delta_function[_qp] =
      (_grad_c[_qp] + RealVectorValue(libMesh::TOLERANCE * libMesh::TOLERANCE)).norm();
}
