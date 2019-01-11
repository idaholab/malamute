//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#ifndef CRAZYKCPLANTFITS_H
#define CRAZYKCPLANTFITS_H

#include "ADMaterial.h"

template <ComputeStage>
class CrazyKCPlantFits;

declareADValidParams(CrazyKCPlantFits);

/**
 * A material that couples a material property
 */
template <ComputeStage compute_stage>
class CrazyKCPlantFits : public ADMaterial<compute_stage>
{
public:
  CrazyKCPlantFits(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

  const Real _c_mu0;
  const Real _c_mu1;
  const Real _c_mu2;
  const Real _c_mu3;
  const Real _Tmax;
  const Real _Tl;
  const Real _T90;
  const Real _beta;
  const Real _c_k0;
  const Real _c_k1;
  const Real _c_cp0;
  const Real _c_cp1;
  const Real _c_rho0;
  const ADVariableValue & _temperature;
  const ADVariableGradient & _grad_temperature;
  ADMaterialProperty(Real) & _mu;
  ADMaterialProperty(Real) & _k;
  ADMaterialProperty(Real) & _cp;
  ADMaterialProperty(Real) & _rho;
  ADMaterialProperty(RealVectorValue) & _grad_k;

  const Real _length_units_per_meter;
  const Real _temperature_units_per_kelvin;
  const Real _mass_units_per_kilogram;
  const Real _time_units_per_second;

  usingMaterialMembers;
};

#endif // CRAZYKCPLANTFITS_H
