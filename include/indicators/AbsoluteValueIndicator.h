/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*               Copyright 2021, Battelle Energy Alliance, LLC              */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

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
