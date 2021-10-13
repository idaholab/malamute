#pragma once

#include "ElementIntegralIndicator.h"

class AbsoluteValueIndicator : public ElementIntegralIndicator
{
public:
  static InputParameters validParams();

  AbsoluteValueIndicator(const InputParameters & parameters);

protected:
  virtual Real computeQpIntegral() override;
};
