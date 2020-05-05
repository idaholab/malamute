#pragma once

#include "Material.h"

/**
 * This class calculates the temperature dependent electrical resistivity of
 * stainless steel, AISI 304, in units of $\Omega$/m
 */
class StainlessSteelElectricalResistivity : public Material
{
public:
  static InputParameters validParams();
  StainlessSteelElectricalResistivity(const InputParameters & parameters);

protected:
  virtual void jacobianSetup();
  virtual void computeQpProperties();

  /**
   * Calculates the electrical resistivity and its derivative with resepect to
   * temperature for AISI 304 stainless steel based on a curve fit to data from
   * Cincotti et al. (2007) AIChE Journal Vol 53, No. 3, page 711, Figure 8b.
   * The electical resistivity units are Ohms/m.
   * Temperature calibration bounds are 296.8K - 1029.0K
   */
  void computeElectricalResistivity();

private:
  /// Coupled temperature variable
  const VariableValue & _temperature;

  ///@{Thermal conductivity (W/(m-K) and associated derivative
  MaterialProperty<Real> & _electrical_resistivity;
  MaterialProperty<Real> & _electrical_resistivity_dT;
  ///@}

  ///Scaling factor applied to the electrial resistivity for a sensitivity study
  const Real _electrical_resistivity_scale_factor;

  /// Check the temperature only at the start of each timestep
  bool _check_temperature_now;
};
