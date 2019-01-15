//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef DISPLACEBOUNDARYBC_H
#define DISPLACEBOUNDARYBC_H

#include "ADNodalBC.h"

template <ComputeStage compute_stage>
class DisplaceBoundaryBC;

declareADValidParams(DisplaceBoundaryBC);

template <ComputeStage compute_stage>
class DisplaceBoundaryBC : public ADNodalBC<compute_stage>
{
public:
  DisplaceBoundaryBC(const InputParameters & parameters);

protected:
  virtual typename Moose::RealType<compute_stage>::type computeQpResidual() override;

  usingNodalBCMembers;

  const typename Moose::RealType<compute_stage>::type & _velocity;
  const Real & _u_old;
};

#endif /* DISPLACEBOUNDARYBC_H */
