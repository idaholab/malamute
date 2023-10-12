/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "StainlessSteelThermalExpansionEigenstrain.h"
#include "NonlinearSystemBase.h"
#include "TimeIntegrator.h"

registerMooseObject("MalamuteApp", StainlessSteelThermalExpansionEigenstrain);
registerMooseObject("MalamuteApp", ADStainlessSteelThermalExpansionEigenstrain);

template <bool is_ad>
InputParameters
StainlessSteelThermalExpansionEigenstrainTempl<is_ad>::validParams()
{
  InputParameters params = ComputeThermalExpansionEigenstrainBaseTempl<is_ad>::validParams();
  params.addClassDescription("Calculates eigenstrain due to isotropic thermal expansion in AISI "
                             "304 Stainless Steel in base SI units");
  params.addParam<Real>("coeffient_thermal_expansion_scale_factor",
                        1.0,
                        "The scaling factor for the coefficient of thermal expansion");

  return params;
}

template <bool is_ad>
StainlessSteelThermalExpansionEigenstrainTempl<
    is_ad>::StainlessSteelThermalExpansionEigenstrainTempl(const InputParameters & parameters)
  : ComputeThermalExpansionEigenstrainBaseTempl<is_ad>(parameters),
    _coeff_thermal_expansion_scale_factor(
        this->template getParam<Real>("coeffient_thermal_expansion_scale_factor"))
{
}

template <bool is_ad>
void
StainlessSteelThermalExpansionEigenstrainTempl<is_ad>::jacobianSetup()
{
  _check_temperature_now = false;
  int number_nonlinear_it = this->_fe_problem.getNonlinearSystemBase(/*nl_sys_num=*/0)
                                .getCurrentNonlinearIterationNumber();
  if (number_nonlinear_it == 0)
    _check_temperature_now = true;
}

template <bool is_ad>
ValueAndDerivative<is_ad>
StainlessSteelThermalExpansionEigenstrainTempl<is_ad>::computeThermalStrain()
{
  if (_check_temperature_now)
  {
    if (_temperature[_qp] < 273.3)
      mooseDoOnce(mooseWarning("The temperature in ",
                               this->_name,
                               " is below the calibration lower range limit at a value of ",
                               MetaPhysicL::raw_value(_temperature[_qp])));
    else if (_temperature[_qp] > 810.5)
      mooseError("The temperature in ",
                 this->_name,
                 " is above the calibration upper range limit at a value of ",
                 MetaPhysicL::raw_value(_temperature[_qp]));

    _check_temperature_now = false;
  }

  const auto cte = computeCoefficientThermalExpansion(_temperature[_qp]);
  return cte * (_temperature[_qp] - this->_stress_free_temperature[_qp]);
}

template <bool is_ad>
ValueAndDerivative<is_ad>
StainlessSteelThermalExpansionEigenstrainTempl<is_ad>::computeCoefficientThermalExpansion(
    const ValueAndDerivative<is_ad> & temperature)
{
  ValueAndDerivative<is_ad> coefficient_thermal_expansion;
  if (temperature < 373)
    coefficient_thermal_expansion = 1.72e-5; // in 1/K
  else if (temperature < 588)
    coefficient_thermal_expansion = 1.78e-5; // in 1/K
  else
    coefficient_thermal_expansion = 1.84e-5; // in 1/K

  return coefficient_thermal_expansion *= _coeff_thermal_expansion_scale_factor;
}

template class StainlessSteelThermalExpansionEigenstrainTempl<false>;
template class StainlessSteelThermalExpansionEigenstrainTempl<true>;
