/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "ComputeThermalExpansionEigenstrainBase.h"

template <bool is_ad>
class StainlessSteelThermalExpansionEigenstrainTempl
  : public ComputeThermalExpansionEigenstrainBaseTempl<is_ad>
{
public:
  static InputParameters validParams();
  StainlessSteelThermalExpansionEigenstrainTempl(const InputParameters & parameters);

protected:
  virtual void jacobianSetup() override;
  virtual ValueAndDerivative<is_ad> computeThermalStrain() override;

private:
  /**
   * Calculates the coefficient of thermal expansion with resepect to temperature
   * and the resulting dilatation strain for AISI Stainless Steel based on the
   *  piecewise data from Cincotti et al. (2007) AIChE Journal Vol 53, No. 3,
   * page 711, Figure 8d. The thermal conductivity units are W/(m-K).
   * Temperature calibration bounds are 273.3K - 810.5K
   */
  ValueAndDerivative<is_ad>
  computeCoefficientThermalExpansion(const ValueAndDerivative<is_ad> & temperature);

  ///Scaling factor appplied to the coefficient for a scaling study
  const Real _coeff_thermal_expansion_scale_factor;

  /// Check the temperature only at the start of each timestep
  bool _check_temperature_now;

  using ComputeThermalExpansionEigenstrainBaseTempl<is_ad>::_qp;
  using ComputeThermalExpansionEigenstrainBaseTempl<is_ad>::_temperature;
};

typedef StainlessSteelThermalExpansionEigenstrainTempl<false>
    StainlessSteelThermalExpansionEigenstrain;
typedef StainlessSteelThermalExpansionEigenstrainTempl<true>
    ADStainlessSteelThermalExpansionEigenstrain;
