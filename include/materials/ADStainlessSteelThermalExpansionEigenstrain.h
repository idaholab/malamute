/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*               Copyright 2021, Battelle Energy Alliance, LLC              */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ComputeThermalExpansionEigenstrainBase.h"

class ADStainlessSteelThermalExpansionEigenstrain : public ADComputeThermalExpansionEigenstrainBase
{
public:
  static InputParameters validParams();
  ADStainlessSteelThermalExpansionEigenstrain(const InputParameters & parameters);

protected:
  virtual void jacobianSetup() override;
  virtual ValueAndDerivative<true> computeThermalStrain() override;

private:
  /**
   * Calculates the coefficient of thermal expansion with resepect to temperature
   * and the resulting dilatation strain for AISI Stainless Steel based on the
   *  piecewise data from Cincotti et al. (2007) AIChE Journal Vol 53, No. 3,
   * page 711, Figure 8d. The thermal conductivity units are W/(m-K).
   * Temperature calibration bounds are 273.3K - 810.5K
   */
  ValueAndDerivative<true>
  computeCoefficientThermalExpansion(const ValueAndDerivative<true> & temperature);

  ///Scaling factor appplied to the coefficient for a scaling study
  const Real _coeff_thermal_expansion_scale_factor;

  /// Check the temperature only at the start of each timestep
  bool _check_temperature_now;
};
