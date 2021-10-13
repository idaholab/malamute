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
