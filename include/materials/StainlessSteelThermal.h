#pragma once

#include "Material.h"

/**
 * This class calculates the temperature dependent thermal properties of
 * stainless steel, AISI 304: the thermal conductivity in W/(m-K) and the
 * heat capacity in J/(kg-K)
 */
class StainlessSteelThermal : public Material
{
public:
  static InputParameters validParams();
  StainlessSteelThermal(const InputParameters & parameters);

protected:
  virtual void jacobianSetup();
  virtual void computeQpProperties();

  /**
   * Calculates the thermal conductivity and its derivative with resepect to
   * temperature for AISI 304 stainless steel based on a curve fit to data from
   * Cincotti et al. (2007) AIChE Journal Vol 53, No. 3, page 711, Figure 8c.
   * The thermal conductivity units are W/(m-K).
   * Temperature calibration bounds are 310.6K - 1032.5K
   */
  void computeThermalConductivity();

  /**
   * Calculates the heat capacity and its derivative with resepect to
   * temperature for AISI 304 stainless steel based on a curve fit to data from
   * Cincotti et al. (2007) AIChE Journal Vol 53, No. 3, page 711, Figure 8a.
   * The units of heat capacity calculted with this method are J/(kg-K).
   * Temperature calibration bounds are 120.8K - 1494.9K
   */
  void computeHeatCapacity();

private:
  /// Coupled temperature variable
  const VariableValue & _temperature;

  ///@{Thermal conductivity (W/(m-K) and associated derivative
  MaterialProperty<Real> & _thermal_conductivity;
  MaterialProperty<Real> & _thermal_conductivity_dT;
  ///@}

  ///@{Heat Capacity (J/(kg-K) and associated derivative
  MaterialProperty<Real> & _heat_capacity;
  MaterialProperty<Real> & _heat_capacity_dT;
  ///@}

  ///@{Scaling factors applied to the thermal properties for a sensitivity study
  const Real _thermal_conductivity_scale_factor;
  const Real _heat_capacity_scale_factor;
  ///@}

  /// Check the temperature only at the start of each timestep
  bool _check_temperature_now;
};
