/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADKernel.h"
#include "MaterialProperty.h"

class ADStressDivergence : public ADKernel
{
public:
  static InputParameters validParams();

  ADStressDivergence(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual();

  ADMaterialProperty<RealVectorValue> const * _stress;
};
