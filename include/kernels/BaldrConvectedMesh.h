/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADVectorKernel.h"

/**
 * This calculates the time derivative for a coupled variable
 **/
class BaldrConvectedMesh : public ADVectorKernel
{
public:
  static InputParameters validParams();

  BaldrConvectedMesh(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  const ADVariableValue & _disp_x_dot;
  const ADVariableValue & _disp_y_dot;
  const ADVariableValue & _disp_z_dot;

  const ADMaterialProperty<Real> & _rho;
};
