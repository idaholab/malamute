/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2022, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADIntegratedBC.h"

class SurfaceTensionBC : public ADIntegratedBC
{
public:
  static InputParameters validParams();

  SurfaceTensionBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  const unsigned _component;
  const ADMaterialProperty<RealVectorValue> & _surface_term_curvature;
  const ADMaterialProperty<RealVectorValue> & _surface_term_gradient1;
  const ADMaterialProperty<RealVectorValue> & _surface_term_gradient2;
};
