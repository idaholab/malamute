//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

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
