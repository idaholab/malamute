//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef GAUSSIANWELDENERGYFLUXBC_H
#define GAUSSIANWELDENERGYFLUXBC_H

#include "ADIntegratedBC.h"

template <ComputeStage>
class GaussianWeldEnergyFluxBC;

declareADValidParams(GaussianWeldEnergyFluxBC);

template <ComputeStage compute_stage>
class GaussianWeldEnergyFluxBC : public ADIntegratedBC<compute_stage>
{
public:
  GaussianWeldEnergyFluxBC(const InputParameters & params);

protected:
  virtual ADResidual computeQpResidual() override;

  const Real _reff;
  const Real _F0;
  const Real _R;
  Function & _x_beam_coord;
  Function & _y_beam_coord;
  Function & _z_beam_coord;

  usingIntegratedBCMembers;
};

#endif /* GAUSSIANWELDENERGYFLUXBC_H */
