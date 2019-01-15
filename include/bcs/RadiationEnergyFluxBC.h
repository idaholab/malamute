//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef RADIATIONENERGYFLUXBC_H
#define RADIATIONENERGYFLUXBC_H

#include "ADIntegratedBC.h"

template <ComputeStage compute_stage>
class RadiationEnergyFluxBC;

declareADValidParams(RadiationEnergyFluxBC);

template <ComputeStage compute_stage>
class RadiationEnergyFluxBC : public ADIntegratedBC<compute_stage>
{
public:
  RadiationEnergyFluxBC(const InputParameters & parameters);

protected:
  virtual ADResidual computeQpResidual() override;

  const ADMaterialProperty(Real) & _sb_constant;
  const ADMaterialProperty(Real) & _absorptivity;
  const Real _ff_temp;

  usingIntegratedBCMembers;
};

#endif /* RADIATIONENERGYFLUXBC_H */
