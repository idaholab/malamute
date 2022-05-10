/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*               Copyright 2021, Battelle Energy Alliance, LLC              */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "ADStainlessSteelThermalExpansionEigenstrain.h"
#include "NonlinearSystemBase.h"
#include "TimeIntegrator.h"
#include "metaphysicl/raw_type.h"

registerMooseObject("MalamuteApp", ADStainlessSteelThermalExpansionEigenstrain);

InputParameters
ADStainlessSteelThermalExpansionEigenstrain::validParams()
{
  InputParameters params = ADComputeThermalExpansionEigenstrainBase::validParams();
  params.addClassDescription("Calculates eigenstrain due to isotropic thermal expansion in AISI "
                             "304 Stainless Steel in base SI units");
  params.addParam<Real>("coeffient_thermal_expansion_scale_factor",
                        1.0,
                        "The scaling factor for the coefficient of thermal expansion");

  return params;
}

ADStainlessSteelThermalExpansionEigenstrain::ADStainlessSteelThermalExpansionEigenstrain(
    const InputParameters & parameters)
  : ADComputeThermalExpansionEigenstrainBase(parameters),
    _coeff_thermal_expansion_scale_factor(
        getParam<Real>("coeffient_thermal_expansion_scale_factor"))
{
}

void
ADStainlessSteelThermalExpansionEigenstrain::jacobianSetup()
{
  _check_temperature_now = false;
  int number_nonlinear_it =
      _fe_problem.getNonlinearSystemBase().getCurrentNonlinearIterationNumber();
  if (number_nonlinear_it == 0)
    _check_temperature_now = true;
}

ValueAndDerivative<true>
ADStainlessSteelThermalExpansionEigenstrain::computeThermalStrain()
{
  if (_check_temperature_now)
  {
    const Real temperature = raw_value(_temperature[_qp]);
    if (temperature < 273.3)
      mooseDoOnce(mooseWarning("The temperature in ",
                               _name,
                               " is below the calibration lower range limit at a value of ",
                               temperature));
    else if (temperature > 810.5)
      mooseError("The temperature in ",
                 _name,
                 " is above the calibration upper range limit at a value of ",
                 temperature);

    _check_temperature_now = false;
  }

  const ADReal cte = computeCoefficientThermalExpansion(_temperature[_qp]);
  return cte * (_temperature[_qp] - _stress_free_temperature[_qp]);
}

ValueAndDerivative<true>
ADStainlessSteelThermalExpansionEigenstrain::computeCoefficientThermalExpansion(
    const ValueAndDerivative<true> & temperature)
{
  ADReal coefficient_thermal_expansion;
  if (temperature < 373)
    coefficient_thermal_expansion = 1.72e-5; // in 1/K
  else if (temperature < 588)
    coefficient_thermal_expansion = 1.78e-5; // in 1/K
  else
    coefficient_thermal_expansion = 1.84e-5; // in 1/K

  return coefficient_thermal_expansion *= _coeff_thermal_expansion_scale_factor;
}
