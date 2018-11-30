//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "AbsoluteValueIndicator.h"
#include "Function.h"

registerMooseObject("MooseApp", AbsoluteValueIndicator);

template <>
InputParameters
validParams<AbsoluteValueIndicator>()
{
  InputParameters params = validParams<ElementIntegralIndicator>();
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
