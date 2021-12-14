/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*               Copyright 2021, Battelle Energy Alliance, LLC              */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "GraphiteElectricalConductivity.h"

#include "libmesh/utility.h"
#include "NonlinearSystemBase.h"
#include "TimeIntegrator.h"

#include "metaphysicl/raw_type.h"

registerMooseObject("MalamuteApp", GraphiteElectricalConductivity);
registerMooseObject("MalamuteApp", ADGraphiteElectricalConductivity);

template <bool is_ad>
InputParameters
GraphiteElectricalConductivityTempl<is_ad>::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription(
      "Calculates the electrical conductivity as a function of temperature for "
      "AT 101 stainless steel in base SI units");
  params.addRequiredCoupledVar("temperature", "Coupled temperature variable");
  params.addParam<Real>("electrical_conductivity_scale_factor",
                        1.0,
                        "The scaling factor for graphite electrical conductivity");
  return params;
}

template <bool is_ad>
GraphiteElectricalConductivityTempl<is_ad>::GraphiteElectricalConductivityTempl(
    const InputParameters & parameters)
  : Material(parameters),
    _temperature(coupledGenericValue<is_ad>("temperature")),
    _electrical_conductivity(declareGenericProperty<Real, is_ad>("electrical_conductivity")),
    _electrical_conductivity_dT(declareProperty<Real>("electrical_conductivity_dT")),
    _electrical_conductivity_scale_factor(getParam<Real>("electrical_conductivity_scale_factor"))
{
}

template <bool is_ad>
void
GraphiteElectricalConductivityTempl<is_ad>::setDerivatives(GenericReal<is_ad> & prop,
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
GraphiteElectricalConductivityTempl<false>::setDerivatives(Real &, Real, const ADReal &)
{
  mooseError("Mistaken call of setDerivatives in a non-AD GraphiteElectricalConductivity version");
}

template <bool is_ad>
void
GraphiteElectricalConductivityTempl<is_ad>::jacobianSetup()
{
  _check_temperature_now = false;
  int number_nonlinear_it =
      _fe_problem.getNonlinearSystemBase().getCurrentNonlinearIterationNumber();
  if (number_nonlinear_it == 0)
    _check_temperature_now = true;
}

template <bool is_ad>
void
GraphiteElectricalConductivityTempl<is_ad>::computeQpProperties()
{
  if (_check_temperature_now)
  {
    if (_temperature[_qp] < 291.7)
      mooseDoOnce(mooseWarning("The temperature in ",
                               _name,
                               " is below the calibration lower range limit at a value of ",
                               MetaPhysicL::raw_value(_temperature[_qp])));
    else if (_temperature[_qp] > 1873.6)
      mooseDoOnce(mooseWarning("The temperature in ",
                 _name,
                 " is above the calibration upper range limit at a value of ",
                 MetaPhysicL::raw_value(_temperature[_qp])));

    _check_temperature_now = false;
  }
  // Allow fall through to calculate the material properties
  computeElectricalConductivity();
}

template <bool is_ad>
void
GraphiteElectricalConductivityTempl<is_ad>::computeElectricalConductivity()
{
  GenericReal<is_ad> electrical_resistivity = -2.705e-15 * Utility::pow<3>(_temperature[_qp]) +
                                              1.263e-11 * Utility::pow<2>(_temperature[_qp]) -
                                              1.836e-8 * _temperature[_qp] + 1.813e-5; // in Ohm/m

  _electrical_conductivity[_qp] = 1.0 / electrical_resistivity;
  _electrical_conductivity[_qp] *= _electrical_conductivity_scale_factor;

  // Apply the chain rule to calculate the derivative
  const Real non_ad_temperature = MetaPhysicL::raw_value(_temperature[_qp]);
  const Real conductivity_dT_inner = 3.0 * -2.705e-15 * Utility::pow<2>(non_ad_temperature) +
                                     2.0 * 1.263e-11 * non_ad_temperature - 1.836e-8;
  _electrical_conductivity_dT[_qp] =
      -1.0 * conductivity_dT_inner /
      Utility::pow<2>(MetaPhysicL::raw_value(electrical_resistivity)) *
      _electrical_conductivity_scale_factor;

  if (is_ad)
    setDerivatives(
        _electrical_conductivity[_qp], _electrical_conductivity_dT[_qp], _temperature[_qp]);
}

template class GraphiteElectricalConductivityTempl<false>;
template class GraphiteElectricalConductivityTempl<true>;
