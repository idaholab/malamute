/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "Material.h"

/**
 * This class calculates the temperature dependent electrical conductivity of
 * AT 101 graphite, in units of m/$\Omega$
 */
template <bool is_ad>
class GraphiteElectricalConductivityTempl : public Material
{
public:
  static InputParameters validParams();
  GraphiteElectricalConductivityTempl(const InputParameters & parameters);

protected:
  virtual void jacobianSetup();
  virtual void computeQpProperties();

private:
  /**
   * Calculates the electrical resistivity and its derivative with resepect to
   * temperature for AT 101 graphite based on a curve fit to data from
   * Cincotti et al. (2007) AIChE Journal Vol 53, No. 3, page 710, Figure 7b.
   * The electical resistivity units are Ohms/m.
   * Temperature calibration bounds are 291.7K - 1873.6K
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

  ///Scaling factor applied to the electrial conductivity for a sensitivity study
  const Real _electrical_conductivity_scale_factor;

  /// Check the temperature only at the start of each timestep
  bool _check_temperature_now;
};

typedef GraphiteElectricalConductivityTempl<false> GraphiteElectricalConductivity;
typedef GraphiteElectricalConductivityTempl<true> ADGraphiteElectricalConductivity;
