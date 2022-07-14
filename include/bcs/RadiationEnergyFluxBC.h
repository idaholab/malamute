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

class RadiationEnergyFluxBC : public ADIntegratedBC
{
public:
  static InputParameters validParams();

  RadiationEnergyFluxBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  const ADMaterialProperty<Real> & _sb_constant;
  const ADMaterialProperty<Real> & _absorptivity;
  const Real _ff_temp;
};
