/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "StainlessSteelThermal.h"

#include "libmesh/utility.h"
#include "NonlinearSystemBase.h"
#include "TimeIntegrator.h"

#include "metaphysicl/raw_type.h"

registerMooseObject("MalamuteApp", StainlessSteelThermal);
registerMooseObject("MalamuteApp", ADStainlessSteelThermal);

template <bool is_ad>
InputParameters
StainlessSteelThermalTempl<is_ad>::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription(
      "Calculates the thermal conductivity and the heat capacity as a function of temperature for "
      "AISI 304 stainless steel in base SI units");
  params.addRequiredCoupledVar("temperature", "Coupled temperature variable");
  params.addParam<Real>("thermal_conductivity_scale_factor",
                        1.0,
                        "The scaling factor for stainless steel thermal conductivity");
  params.addParam<Real>(
      "heat_capacity_scale_factor", 1.0, "The scaling factor for stainless steel heat capacity");
  return params;
}

template <bool is_ad>
StainlessSteelThermalTempl<is_ad>::StainlessSteelThermalTempl(const InputParameters & parameters)
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
StainlessSteelThermalTempl<is_ad>::setDerivatives(GenericReal<is_ad> & prop,
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
StainlessSteelThermalTempl<false>::setDerivatives(Real &, Real, const ADReal &)
{
  mooseError("Mistaken call of setDerivatives in a non-AD StainlessSteelThermal version");
}

template <bool is_ad>
void
StainlessSteelThermalTempl<is_ad>::jacobianSetup()
{
  _check_temperature_now = false;
  int number_nonlinear_it =
      _fe_problem.getNonlinearSystemBase(/*nl_sys_num=*/0).getCurrentNonlinearIterationNumber();
  if (number_nonlinear_it == 0)
    _check_temperature_now = true;
}

template <bool is_ad>
void
StainlessSteelThermalTempl<is_ad>::computeQpProperties()
{
  // thermal conductivity limits are more conservative, so check only against those
  if (_check_temperature_now)
  {
    if (_temperature[_qp] < 310.7)
      mooseDoOnce(mooseWarning("The temperature in ",
                               _name,
                               " is below the calibration lower range limit at a value of ",
                               MetaPhysicL::raw_value(_temperature[_qp])));
    else if (_temperature[_qp] > 1032.5)
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
StainlessSteelThermalTempl<is_ad>::computeThermalConductivity()
{
  _thermal_conductivity[_qp] =
      (0.0144 * _temperature[_qp] + 10.55) * _thermal_conductivity_scale_factor; // in W/(m-K)
  _thermal_conductivity_dT[_qp] = 0.0144 * _thermal_conductivity_scale_factor;

  if (is_ad)
    setDerivatives(_thermal_conductivity[_qp], _thermal_conductivity_dT[_qp], _temperature[_qp]);
}

template <bool is_ad>
void
StainlessSteelThermalTempl<is_ad>::computeHeatCapacity()
{
  const Real nonad_temperature = MetaPhysicL::raw_value(_temperature[_qp]);

  _heat_capacity[_qp] = 2.484e-7 * Utility::pow<3>(_temperature[_qp]) -
                        7.321e-4 * Utility::pow<2>(_temperature[_qp]) + 0.840 * _temperature[_qp] +
                        253.7; // in J/(K-kg)
  _heat_capacity[_qp] *= _heat_capacity_scale_factor;
  _heat_capacity_dT[_qp] = 3.0 * 2.484e-7 * Utility::pow<2>(nonad_temperature) -
                           2.0 * 7.321e-4 * nonad_temperature + 0.840;
  _heat_capacity_dT[_qp] *= _heat_capacity_scale_factor;

  if (is_ad)
    setDerivatives(_heat_capacity[_qp], _heat_capacity_dT[_qp], _temperature[_qp]);
}

template class StainlessSteelThermalTempl<false>;
template class StainlessSteelThermalTempl<true>;
