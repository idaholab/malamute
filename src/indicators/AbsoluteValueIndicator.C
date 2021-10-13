#include "AbsoluteValueIndicator.h"
#include "Function.h"

registerMooseObject("BaldrApp", AbsoluteValueIndicator);

InputParameters
AbsoluteValueIndicator::validParams()
{
  InputParameters params = ElementIntegralIndicator::validParams();
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
