/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*               Copyright 2021, Battelle Energy Alliance, LLC              */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "Material.h"

/**
 * This class calculates the temperature dependent electrical conductivity of
 * stainless steel, AISI 304, in units of m/$\Omega$
 */
template <bool is_ad>
class StainlessSteelElectricalConductivityTempl : public Material
{
public:
  static InputParameters validParams();
  StainlessSteelElectricalConductivityTempl(const InputParameters & parameters);

protected:
  virtual void jacobianSetup();
  virtual void computeQpProperties();

private:
  /**
   * Calculates the electrical conductivity and its derivative with resepect to
   * temperature for AISI 304 stainless steel based on a curve fit to data from
   * Cincotti et al. (2007) AIChE Journal Vol 53, No. 3, page 711, Figure 8b.
   * The electical conductivity units are m/Ohms.
   * Temperature calibration bounds are 296.8K - 1029.0K
   */
  void computeElectricalConductivity();

  /**
   * Handles derivatives for the AD version
   */
  void setDerivatives(GenericReal<is_ad> & prop, Real dprop_dT, const ADReal & ad_T);

  /// Coupled temperature variable
  const GenericVariableValue<is_ad> & _temperature;

  ///@{Electrical conductivity (m/$\Omega$) and associated derivative
  GenericMaterialProperty<Real, is_ad> & _electrical_conductivity;
  MaterialProperty<Real> & _electrical_conductivity_dT;
  ///@}

  /// Scaling factor applied to the electrial conductivity for a sensitivity study
  const Real _electrical_conductivity_scale_factor;

  /// Check the temperature only at the start of each timestep
  bool _check_temperature_now;
};

typedef StainlessSteelElectricalConductivityTempl<false> StainlessSteelElectricalConductivity;
typedef StainlessSteelElectricalConductivityTempl<true> ADStainlessSteelElectricalConductivity;
