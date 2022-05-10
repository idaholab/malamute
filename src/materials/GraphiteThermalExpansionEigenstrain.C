/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*               Copyright 2021, Battelle Energy Alliance, LLC              */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "GraphiteThermalExpansionEigenstrain.h"
#include "NonlinearSystemBase.h"
#include "TimeIntegrator.h"

registerMooseObject("MalamuteApp", GraphiteThermalExpansionEigenstrain);
registerMooseObject("MalamuteApp", ADGraphiteThermalExpansionEigenstrain);

template <bool is_ad>
InputParameters
GraphiteThermalExpansionEigenstrainTempl<is_ad>::validParams()
{
  InputParameters params = ComputeThermalExpansionEigenstrainBaseTempl<is_ad>::validParams();
  params.addClassDescription(
      "Calculates eigenstrain due to isotropic thermal expansion in AT 101 graphite");
  params.addParam<Real>("coeffient_thermal_expansion_scale_factor",
                        1.0,
                        "The scaling factor for the coefficient of thermal expansion");

  return params;
}

template <bool is_ad>
GraphiteThermalExpansionEigenstrainTempl<is_ad>::GraphiteThermalExpansionEigenstrainTempl(
    const InputParameters & parameters)
  : ComputeThermalExpansionEigenstrainBaseTempl<is_ad>(parameters),
    _coeff_thermal_expansion_scale_factor(
        this->template getParam<Real>("coeffient_thermal_expansion_scale_factor"))
{
}

template <bool is_ad>
void
GraphiteThermalExpansionEigenstrainTempl<is_ad>::jacobianSetup()
{
  _check_temperature_now = false;
  int number_nonlinear_it =
      this->_fe_problem.getNonlinearSystemBase().getCurrentNonlinearIterationNumber();
  if (number_nonlinear_it == 0)
    _check_temperature_now = true;
}

template <bool is_ad>
ValueAndDerivative<is_ad>
GraphiteThermalExpansionEigenstrainTempl<is_ad>::computeThermalStrain()
{
  if (_check_temperature_now)
  {
    if (_temperature[_qp] < 290.9)
      mooseDoOnce(mooseWarning("The temperature in ",
                               this->_name,
                               " is below the calibration lower range limit at a value of ",
                               MetaPhysicL::raw_value(_temperature[_qp])));
    else if (_temperature[_qp] > 2383.0)
      mooseDoOnce(mooseWarning("The temperature in ",
                               this->_name,
                               " is above the calibration upper range limit at a value of ",
                               MetaPhysicL::raw_value(_temperature[_qp])));

    _check_temperature_now = false;
  }

  const auto cte = computeCoefficientThermalExpansion(_temperature[_qp]);
  return cte * (_temperature[_qp] - this->_stress_free_temperature[_qp]);
}

template <bool is_ad>
ValueAndDerivative<is_ad>
GraphiteThermalExpansionEigenstrainTempl<is_ad>::computeCoefficientThermalExpansion(
    const ValueAndDerivative<is_ad> & temperature)
{
  const auto coefficient_thermal_expansion =
      1.996e-6 * std::log(4.799e-2 * temperature) - 4.041e-6; // in 1/K
  return coefficient_thermal_expansion * _coeff_thermal_expansion_scale_factor;
}
