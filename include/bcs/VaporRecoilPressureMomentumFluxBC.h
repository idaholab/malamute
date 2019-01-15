//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef VAPORRECOILPRESSUREMOMENTUMFLUXBC_H
#define VAPORRECOILPRESSUREMOMENTUMFLUXBC_H

#include "ADIntegratedBC.h"

template <ComputeStage compute_stage>
class VaporRecoilPressureMomentumFluxBC;

declareADValidParams(VaporRecoilPressureMomentumFluxBC);

template <ComputeStage compute_stage>
class VaporRecoilPressureMomentumFluxBC : public ADIntegratedBC<compute_stage>
{
public:
  VaporRecoilPressureMomentumFluxBC(const InputParameters & parameters);

protected:
  virtual ADResidual computeQpResidual() override;

  usingIntegratedBCMembers;

  const unsigned _component;
  const ADMaterialProperty(Real) & _rc_pressure;
};

#endif /* VAPORRECOILPRESSUREMOMENTUMFLUXBC_H */
