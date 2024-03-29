/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "AbsoluteValueIndicator.h"
#include "Function.h"

registerMooseObject("MalamuteApp", AbsoluteValueIndicator);

InputParameters
AbsoluteValueIndicator::validParams()
{
  InputParameters params = ElementIntegralIndicator::validParams();
  params.addClassDescription(
      "Computes the absolute value of the provided variable for use as an error indicator.");
  return params;
}

AbsoluteValueIndicator::AbsoluteValueIndicator(const InputParameters & parameters)
  : ElementIntegralIndicator(parameters)
{
}

Real
AbsoluteValueIndicator::computeQpIntegral()
{
  return std::abs(_u[_qp]) / _JxW[_qp];
}
