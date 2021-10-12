//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADIntegratedBC.h"

class PenaltyDisplaceBoundaryBC : public ADIntegratedBC
{
public:
  static InputParameters validParams();

  PenaltyDisplaceBoundaryBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  const ADVariableValue & _vel_x;
  const ADVariableValue & _vel_y;
  const ADVariableValue & _vel_z;
  const ADVariableValue & _disp_x_dot;
  const ADVariableValue & _disp_y_dot;
  const ADVariableValue & _disp_z_dot;
  const Real _penalty;
};
