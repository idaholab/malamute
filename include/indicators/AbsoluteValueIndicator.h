#ifndef ABSOLUTEVALUEINDICATOR_H
#define ABSOLUTEVALUEINDICATOR_H

#include "ElementIntegralIndicator.h"

class AbsoluteValueIndicator;

template <>
InputParameters validParams<AbsoluteValueIndicator>();

class AbsoluteValueIndicator : public ElementIntegralIndicator
{
public:
  AbsoluteValueIndicator(const InputParameters & parameters);

protected:
  virtual Real computeQpIntegral() override;
};

#endif /* ABSOLUTEVALUEINDICATOR_H */
