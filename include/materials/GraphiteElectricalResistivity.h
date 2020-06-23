#pragma once

#include "Material.h"

/**
 * This class calculates the temperature dependent electrical resistivity of
 * AT 101 graphite, in units of $\Omega$/m
 */
template <bool is_ad>
class GraphiteElectricalResistivityTempl : public Material
{
public:
  static InputParameters validParams();
  GraphiteElectricalResistivityTempl(const InputParameters & parameters);

protected:
  virtual void jacobianSetup();
  virtual void computeQpProperties();

  /**
   * Calculates the electrical resistivity and its derivative with resepect to
   * temperature for AT 101 graphite based on a curve fit to data from
   * Cincotti et al. (2007) AIChE Journal Vol 53, No. 3, page 710, Figure 7b.
   * The electical resistivity units are Ohms/m.
   * Temperature calibration bounds are 291.7K - 1873.6K
   */
  void computeElectricalResistivity();

private:
  /// Coupled temperature variable
  const VariableValue & _temperature;

  ///@{Electrical resistivity ($\Omega$/m) and associated derivative
  GenericMaterialProperty<Real, is_ad> & _electrical_resistivity;
  GenericMaterialProperty<Real, is_ad> & _electrical_resistivity_dT;
  ///@}

  ///Scaling factor applied to the electrial resistivity for a sensitivity study
  const Real _electrical_resistivity_scale_factor;

  /// Check the temperature only at the start of each timestep
  bool _check_temperature_now;
};

typedef GraphiteElectricalResistivityTempl<false> GraphiteElectricalResistivity;
typedef GraphiteElectricalResistivityTempl<true> ADGraphiteElectricalResistivity;
