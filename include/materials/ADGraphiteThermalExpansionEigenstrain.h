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

class ADGraphiteThermalExpansionEigenstrain : public ADComputeThermalExpansionEigenstrainBase
{
public:
  static InputParameters validParams();
  ADGraphiteThermalExpansionEigenstrain(const InputParameters & parameters);

protected:
  virtual void jacobianSetup() override;
  virtual void computeThermalStrain(ADReal & thermal_strain, Real *) override;

private:
  /**
   * Calculates the coefficient of thermal expansion and its derivative with
   * resepect to temperature for AT 101 graphite based on a curve fit to data
   * from Cincotti et al. (2007) AIChE Journal Vol 53, No. 3, page 710,
   * Figure 7d. The thermal conductivity units are W/(m-K).
   * Temperature calibration bounds are 290.9K - 2383.0K
   */
  ADReal computeCoefficientThermalExpansion(const ADReal & temperature);

  ///Scaling factor appplied to the coefficient for a scaling study
  const Real _coeff_thermal_expansion_scale_factor;

  /// Check the temperature only at the start of each timestep
  bool _check_temperature_now;
};
