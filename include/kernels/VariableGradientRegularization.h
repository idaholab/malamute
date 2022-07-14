/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2022, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADVectorKernel.h"

/**
 * This class performs L2 projection of a variable's gradient onto a new vector variable.
 */
class VariableGradientRegularization : public ADVectorKernel
{
public:
  static InputParameters validParams();

  VariableGradientRegularization(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

  /// Gradient of the variable that needs regulization
  const ADVariableGradient & _grad_c;
};
