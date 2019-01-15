//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef SURFACETENSIONBC_H
#define SURFACETENSIONBC_H

#include "ADIntegratedBC.h"

template <ComputeStage compute_stage>
class SurfaceTensionBC;

declareADValidParams(SurfaceTensionBC);

template <ComputeStage compute_stage>
class SurfaceTensionBC : public ADIntegratedBC<compute_stage>
{
public:
  SurfaceTensionBC(const InputParameters & parameters);

protected:
  virtual ADResidual computeQpResidual() override;

  usingIntegratedBCMembers;

  const unsigned _component;
  const ADMaterialProperty(RealVectorValue) & _surface_term_curvature;
  const ADMaterialProperty(RealVectorValue) & _surface_term_gradient1;
  const ADMaterialProperty(RealVectorValue) & _surface_term_gradient2;
};

#endif /* SURFACETENSIONBC_H */
