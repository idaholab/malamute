/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2025, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "Material.h"

/**
 * This class calculates the temperature dependent thermal properties of
 * AT 1010 graphite: the thermal conductivity in W/(m-K) and the
 * heat capacity in J/(kg-K)
 */
template <bool is_ad>
class GraphiteThermalTempl : public Material
{
public:
  static InputParameters validParams();
  GraphiteThermalTempl(const InputParameters & parameters);

protected:
  virtual void jacobianSetup();
  virtual void computeQpProperties();

private:
  /**
   * Calculates the thermal conductivity and its derivative with resepect to
   * temperature for AT 101 graphite based on a curve fit to data from
   * Cincotti et al. (2007) AIChE Journal Vol 53, No. 3, page 710, Figure 7c.
   * The thermal conductivity units are W/(m-K).
   * Temperature calibration bounds are 268.9K - 3312.0K
   */
  void computeThermalConductivity();

  /**
   * Calculates the heat capacity and its derivative with resepect to
   * temperature for AT 101 graphite based on a curve fit to data from
   * Cincotti et al. (2007) AIChE Journal Vol 53, No. 3, page 710, Figure 7a.
   * The units of heat capacity calculted with this method are J/(kg-K).
   * Temperature calibration bounds are 495.5K - 4097.7K
   */
  void computeHeatCapacity();

  /**
   * Handles derivatives for the AD version
   */
  void setDerivatives(GenericReal<is_ad> & prop, Real dprop_dT, const ADReal & ad_T);

  /// Coupled temperature variable
  const GenericVariableValue<is_ad> & _temperature;

  ///@{Thermal conductivity (W/(m-K) and associated derivative
  GenericMaterialProperty<Real, is_ad> & _thermal_conductivity;
  MaterialProperty<Real> & _thermal_conductivity_dT;
  ///@}

  ///@{Heat Capacity (J/(kg-K) and associated derivative
  GenericMaterialProperty<Real, is_ad> & _heat_capacity;
  MaterialProperty<Real> & _heat_capacity_dT;
  ///@}

  ///@{Scaling factors applied to the thermal properties for a sensitivity study
  const Real _thermal_conductivity_scale_factor;
  const Real _heat_capacity_scale_factor;
  ///@}

  /// Check the temperature only at the start of each timestep
  bool _check_temperature_now;
};

typedef GraphiteThermalTempl<false> GraphiteThermal;
typedef GraphiteThermalTempl<true> ADGraphiteThermal;
