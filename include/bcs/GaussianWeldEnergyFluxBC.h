/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ADIntegratedBC.h"

class GaussianWeldEnergyFluxBC : public ADIntegratedBC
{
public:
  static InputParameters validParams();

  GaussianWeldEnergyFluxBC(const InputParameters & params);

protected:
  virtual ADReal computeQpResidual() override;

  const Real _reff;
  const Real _F0;
  const Real _R;
  const Function & _x_beam_coord;
  const Function & _y_beam_coord;
  const Function & _z_beam_coord;
};
