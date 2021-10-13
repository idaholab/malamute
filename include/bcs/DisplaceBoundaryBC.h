#pragma once

#include "ADNodalBC.h"

class DisplaceBoundaryBC : public ADNodalBC
{
public:
  static InputParameters validParams();

  DisplaceBoundaryBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  const ADReal & _velocity;
  const Real & _u_old;
};
