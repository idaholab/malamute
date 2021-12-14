#include "ADGraphiteThermalExpansionEigenstrain.h"
#include "NonlinearSystemBase.h"
#include "TimeIntegrator.h"
#include "metaphysicl/raw_type.h"

registerMooseObject("MalamuteApp", ADGraphiteThermalExpansionEigenstrain);

InputParameters
ADGraphiteThermalExpansionEigenstrain::validParams()
{
  InputParameters params = ADComputeThermalExpansionEigenstrainBase::validParams();
  params.addClassDescription(
      "Calculates eigenstrain due to isotropic thermal expansion in AT 101 graphite");
  params.addParam<Real>("coeffient_thermal_expansion_scale_factor",
                        1.0,
                        "The scaling factor for the coefficient of thermal expansion");

  return params;
}

ADGraphiteThermalExpansionEigenstrain::ADGraphiteThermalExpansionEigenstrain(
    const InputParameters & parameters)
  : ADComputeThermalExpansionEigenstrainBase(parameters),
    _coeff_thermal_expansion_scale_factor(
        getParam<Real>("coeffient_thermal_expansion_scale_factor"))
{
}

void
ADGraphiteThermalExpansionEigenstrain::jacobianSetup()
{
  _check_temperature_now = false;
  int number_nonlinear_it =
      _fe_problem.getNonlinearSystemBase().getCurrentNonlinearIterationNumber();
  if (number_nonlinear_it == 0)
    _check_temperature_now = true;
}

void
ADGraphiteThermalExpansionEigenstrain::computeThermalStrain(ADReal & thermal_strain)
{
  const Real temperature = raw_value(_temperature[_qp]);
  if (_check_temperature_now)
  {
    if (temperature < 290.9)
      mooseDoOnce(mooseWarning("The temperature in ",
                 _name,
                 " is below the calibration lower range limit at a value of ",
                 temperature));
    else if (temperature > 2383.0)
      mooseDoOnce(mooseWarning("The temperature in ",
                 _name,
                 " is above the calibration upper range limit at a value of ",
                 temperature));

    _check_temperature_now = false;
  }

  const ADReal cte = computeCoefficientThermalExpansion(_temperature[_qp]);
  thermal_strain = cte * (_temperature[_qp] - _stress_free_temperature[_qp]);
}

ADReal
ADGraphiteThermalExpansionEigenstrain::computeCoefficientThermalExpansion(
    const ADReal & temperature)
{
  ADReal coefficient_thermal_expansion =
      1.996e-6 * std::log(4.799e-2 * temperature) - 4.041e-6; // in 1/K
  return coefficient_thermal_expansion *= _coeff_thermal_expansion_scale_factor;
}
