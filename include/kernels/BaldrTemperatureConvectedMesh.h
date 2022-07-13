/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2022, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADKernel.h"

/**
 * This calculates the time derivative for a coupled variable
 **/
class BaldrTemperatureConvectedMesh : public ADKernel
{
public:
  static InputParameters validParams();

  BaldrTemperatureConvectedMesh(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  const ADVariableValue & _disp_x_dot;
  const ADVariableValue & _disp_y_dot;
  const ADVariableValue & _disp_z_dot;

  const ADMaterialProperty<Real> & _rho;
  const ADMaterialProperty<Real> & _cp;
};
