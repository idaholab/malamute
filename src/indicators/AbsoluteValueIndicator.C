#include "AbsoluteValueIndicator.h"
#include "Function.h"

registerMooseObject("BaldrApp", AbsoluteValueIndicator);

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
