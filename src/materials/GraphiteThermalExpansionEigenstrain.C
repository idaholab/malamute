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

InputParameters
GraphiteThermalExpansionEigenstrain::validParams()
{
  InputParameters params = ComputeThermalExpansionEigenstrainBase::validParams();
  params.addClassDescription(
      "Calculates eigenstrain due to isotropic thermal expansion in AT 101 graphite");
  params.addParam<Real>("coeffient_thermal_expansion_scale_factor",
                        1.0,
                        "The scaling factor for the coefficient of thermal expansion");

  return params;
}

GraphiteThermalExpansionEigenstrain::GraphiteThermalExpansionEigenstrain(
    const InputParameters & parameters)
  : ComputeThermalExpansionEigenstrainBase(parameters),
    _coeff_thermal_expansion_scale_factor(
        getParam<Real>("coeffient_thermal_expansion_scale_factor"))
{
}

void
GraphiteThermalExpansionEigenstrain::jacobianSetup()
{
  _check_temperature_now = false;
  int number_nonlinear_it =
      _fe_problem.getNonlinearSystemBase().getCurrentNonlinearIterationNumber();
  if (number_nonlinear_it == 0)
    _check_temperature_now = true;
}

void
GraphiteThermalExpansionEigenstrain::computeThermalStrain(Real & thermal_strain,
                                                          Real & instantaneous_cte)
{
  if (_check_temperature_now)
  {
    if (_temperature[_qp] < 290.9)
      mooseDoOnce(mooseWarning("The temperature in ",
                 _name,
                 " is below the calibration lower range limit at a value of ",
                 _temperature[_qp]));
    else if (_temperature[_qp] > 2383.0)
      mooseDoOnce(mooseWarning("The temperature in ",
                 _name,
                 " is above the calibration upper range limit at a value of ",
                 _temperature[_qp]));

    _check_temperature_now = false;
  }

  const Real cte = computeCoefficientThermalExpansion(_temperature[_qp]);
  thermal_strain = cte * (_temperature[_qp] - _stress_free_temperature[_qp]);
  instantaneous_cte = cte;
}

Real
GraphiteThermalExpansionEigenstrain::computeCoefficientThermalExpansion(const Real & temperature)
{
  Real coefficient_thermal_expansion =
      1.996e-6 * std::log(4.799e-2 * temperature) - 4.041e-6; // in 1/K
  return coefficient_thermal_expansion *= _coeff_thermal_expansion_scale_factor;
}
