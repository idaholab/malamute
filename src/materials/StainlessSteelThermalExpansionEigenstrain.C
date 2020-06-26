#include "StainlessSteelThermalExpansionEigenstrain.h"
#include "NonlinearSystemBase.h"
#include "TimeIntegrator.h"

registerMooseObject("FreyaApp", StainlessSteelThermalExpansionEigenstrain);

InputParameters
StainlessSteelThermalExpansionEigenstrain::validParams()
{
  InputParameters params = ComputeThermalExpansionEigenstrainBase::validParams();
  params.addClassDescription("Calculates eigenstrain due to isotropic thermal expansion in AISI "
                             "304 Stainless Steel in base SI units");
  params.addParam<Real>("coeffient_thermal_expansion_scale_factor",
                        1.0,
                        "The scaling factor for the coefficient of thermal expansion");

  return params;
}

StainlessSteelThermalExpansionEigenstrain::StainlessSteelThermalExpansionEigenstrain(
    const InputParameters & parameters)
  : ComputeThermalExpansionEigenstrainBase(parameters),
    _coeff_thermal_expansion_scale_factor(
        getParam<Real>("coeffient_thermal_expansion_scale_factor"))
{
}

void
StainlessSteelThermalExpansionEigenstrain::jacobianSetup()
{
  _check_temperature_now = false;
  int number_nonlinear_it =
      _fe_problem.getNonlinearSystemBase().getCurrentNonlinearIterationNumber();
  if (number_nonlinear_it == 0)
    _check_temperature_now = true;
}

void
StainlessSteelThermalExpansionEigenstrain::computeThermalStrain(Real & thermal_strain,
                                                                Real & instantaneous_cte)
{
  if (_check_temperature_now)
  {
    if (_temperature[_qp] < 273.3)
      mooseError("The temperature in ",
                 _name,
                 " is below the calibration lower range limit at a value of ",
                 _temperature[_qp]);
    else if (_temperature[_qp] > 810.5)
      mooseError("The temperature in ",
                 _name,
                 " is above the calibration upper range limit at a value of ",
                 _temperature[_qp]);

    _check_temperature_now = false;
  }

  const Real cte = computeCoefficientThermalExpansion(_temperature[_qp]);
  thermal_strain = cte * (_temperature[_qp] - _stress_free_temperature[_qp]);
  instantaneous_cte = cte;
}

Real
StainlessSteelThermalExpansionEigenstrain::computeCoefficientThermalExpansion(
    const Real & temperature)
{
  Real coefficient_thermal_expansion;
  if (temperature < 373)
    coefficient_thermal_expansion = 1.72e-5; // in 1/K
  else if (temperature < 588)
    coefficient_thermal_expansion = 1.78e-5; // in 1/K
  else
    coefficient_thermal_expansion = 1.84e-5; // in 1/K

  return coefficient_thermal_expansion *= _coeff_thermal_expansion_scale_factor;
}
