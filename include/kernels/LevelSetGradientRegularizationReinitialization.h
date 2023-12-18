/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADKernelGrad.h"

/**
 * Implements the re-initialization equation that uses regularized gradient.
 */
class LevelSetGradientRegularizationReinitialization : public ADKernelGrad
{
public:
  static InputParameters validParams();

  LevelSetGradientRegularizationReinitialization(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  /// Regularized gradient of the level set variable at time, \tau = 0.
  const VectorVariableValue & _grad_c;

  /// Interface thickness
  const Real & _epsilon;
};
