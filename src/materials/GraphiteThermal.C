/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*               Copyright 2021, Battelle Energy Alliance, LLC              */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "GraphiteThermal.h"

#include "libmesh/utility.h"
#include "NonlinearSystemBase.h"
#include "TimeIntegrator.h"

#include "metaphysicl/raw_type.h"

registerMooseObject("MalamuteApp", GraphiteThermal);
registerMooseObject("MalamuteApp", ADGraphiteThermal);

template <bool is_ad>
InputParameters
GraphiteThermalTempl<is_ad>::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription(
      "Calculates the thermal conductivity and the heat capacity as a function of temperature for "
      "AT 101 graphite in base SI units");
  params.addRequiredCoupledVar("temperature", "Coupled temperature variable");
  params.addParam<Real>("thermal_conductivity_scale_factor",
                        1.0,
                        "The scaling factor for graphite thermal conductivity");
  params.addParam<Real>(
      "heat_capacity_scale_factor", 1.0, "The scaling factor for graphite heat capacity");
  return params;
}

template <bool is_ad>
GraphiteThermalTempl<is_ad>::GraphiteThermalTempl(const InputParameters & parameters)
  : Material(parameters),
    _temperature(coupledGenericValue<is_ad>("temperature")),
    _thermal_conductivity(declareGenericProperty<Real, is_ad>("thermal_conductivity")),
    _thermal_conductivity_dT(declareProperty<Real>("thermal_conductivity_dT")),
    _heat_capacity(declareGenericProperty<Real, is_ad>("heat_capacity")),
    _heat_capacity_dT(declareProperty<Real>("heat_capacity_dT")),
    _thermal_conductivity_scale_factor(getParam<Real>("thermal_conductivity_scale_factor")),
    _heat_capacity_scale_factor(getParam<Real>("heat_capacity_scale_factor"))
{
}

template <bool is_ad>
void
GraphiteThermalTempl<is_ad>::setDerivatives(GenericReal<is_ad> & prop,
                                            Real dprop_dT,
                                            const ADReal & ad_T)
{
  if (ad_T < 0)
    prop.derivatives() = 0;
  else
    prop.derivatives() = dprop_dT * ad_T.derivatives();
}

template <>
void
GraphiteThermalTempl<false>::setDerivatives(Real &, Real, const ADReal &)
{
  mooseError("Mistaken call of setDerivatives in a non-AD GraphiteThermal version");
}

template <bool is_ad>
void
GraphiteThermalTempl<is_ad>::jacobianSetup()
{
  _check_temperature_now = false;
  int number_nonlinear_it =
      _fe_problem.getNonlinearSystemBase().getCurrentNonlinearIterationNumber();
  if (number_nonlinear_it == 0)
    _check_temperature_now = true;
}

template <bool is_ad>
void
GraphiteThermalTempl<is_ad>::computeQpProperties()
{
  // select the most conservative calibation range limits to check against:
  if (_check_temperature_now)
  {
    if (_temperature[_qp] < 495.4) // heat capacity calibration
      mooseDoOnce(mooseWarning("The temperature in ",
                               _name,
                               " is below the calibration lower range limit at a value of ",
                               MetaPhysicL::raw_value(_temperature[_qp])));
    else if (_temperature[_qp] > 3312.0) // thermal conductivity calibration range
      mooseError("The temperature in ",
                 _name,
                 " is above the calibration upper range limit at a value of ",
                 MetaPhysicL::raw_value(_temperature[_qp]));

    _check_temperature_now = false;
  }
  // Allow fall through to calculate the thermal material properties
  computeThermalConductivity();
  computeHeatCapacity();
}

template <bool is_ad>
void
GraphiteThermalTempl<is_ad>::computeThermalConductivity()
{
  _thermal_conductivity[_qp] = -4.418e-12 * Utility::pow<4>(_temperature[_qp]) +
                               2.904e-8 * Utility::pow<3>(_temperature[_qp]) -
                               4.688e-5 * Utility::pow<2>(_temperature[_qp]) -
                               0.0316 * _temperature[_qp] + 119.659; // in W/(m-K)
  _thermal_conductivity_dT[_qp] =
      4.0 * -4.418e-12 * Utility::pow<3>(MetaPhysicL::raw_value(_temperature[_qp])) +
      3.0 * 2.904e-8 * Utility::pow<2>(MetaPhysicL::raw_value(_temperature[_qp])) -
      2.0 * 4.688e-5 * MetaPhysicL::raw_value(_temperature[_qp]) - 0.0316; // in W/(m-K)

  _thermal_conductivity[_qp] *= _thermal_conductivity_scale_factor;
  _thermal_conductivity_dT[_qp] *= _thermal_conductivity_scale_factor;

  if (is_ad)
    setDerivatives(_thermal_conductivity[_qp], _thermal_conductivity_dT[_qp], _temperature[_qp]);
}

template <bool is_ad>
void
GraphiteThermalTempl<is_ad>::computeHeatCapacity()
{
  const Real nonad_temperature = MetaPhysicL::raw_value(_temperature[_qp]);

  if (nonad_temperature < 2004)
  {
    _heat_capacity[_qp] = 3.852e-7 * Utility::pow<3>(_temperature[_qp]) -
                          1.921e-3 * Utility::pow<2>(_temperature[_qp]) +
                          3.318 * _temperature[_qp] + 16.282; // in J/(K-kg)
    _heat_capacity_dT[_qp] = 3.852e-7 * 3.0 * Utility::pow<2>(nonad_temperature) -
                             1.921e-3 * 2.0 * nonad_temperature + 3.318;
  }
  else
  {
    _heat_capacity[_qp] = 5.878e-2 * _temperature[_qp] + 1931.166; // in J/(K-kg)
    _heat_capacity_dT[_qp] = 5.878e-2;
  }

  _heat_capacity[_qp] *= _heat_capacity_scale_factor;
  _heat_capacity_dT[_qp] *= _heat_capacity_scale_factor;

  if (is_ad)
    setDerivatives(_heat_capacity[_qp], _heat_capacity_dT[_qp], _temperature[_qp]);
}

template class GraphiteThermalTempl<false>;
template class GraphiteThermalTempl<true>;
