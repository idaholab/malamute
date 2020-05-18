/*************************************************/
/*           Will be part of Freya App           */
/*************************************************/

#include "CoupledSimpleRadiativeHeatFluxBC.h"

registerMooseObject("FreyaApp", CoupledSimpleRadiativeHeatFluxBC);

InputParameters
CoupledSimpleRadiativeHeatFluxBC::validParams()
{
  InputParameters params = IntegratedBC::validParams();
  params.addClassDescription(
      "Radiative heat transfer boundary condition with the far field temperature, of an assummed "
      "black body, given by auxiliary variables and constant emissivity");
  params.addCoupledVar("alpha", 1., "Volume fraction of components");
  params.addRequiredCoupledVar("T_infinity",
                               "Field holding the far-field temperature for each component");
  params.addRequiredParam<std::vector<Real>>(
      "emissivity", "The emissivity of the surface to which this boundary belongs");
  params.addParam<Real>("sigma", 5.67e-8, "The Stefan-Boltzmann constant");

  return params;
}

CoupledSimpleRadiativeHeatFluxBC::CoupledSimpleRadiativeHeatFluxBC(
    const InputParameters & parameters)
  : IntegratedBC(parameters),
    _n_components(coupledComponents("T_infinity")),
    _emissivity(getParam<std::vector<Real>>("emissivity")),
    _sigma(getParam<Real>("sigma"))
{
  if (coupledComponents("alpha") != _n_components)
    paramError(
        "alpha",
        "The number of coupled components does not match the number of `T_infinity` components.");

  _T_infinity.resize(_n_components);
  _alpha.resize(_n_components);
  for (std::size_t c = 0; c < _n_components; c++)
  {
    _T_infinity[c] = &coupledValue("T_infinity", c);
    _alpha[c] = &coupledValue("alpha", c);
  }

  if (_emissivity.size() != _n_components)
    paramError(
        "emissivity",
        "The number of coupled components does not match the number of `T_infinity` components.");
}

Real
CoupledSimpleRadiativeHeatFluxBC::computeQpResidual()
{
  Real q = 0;
  for (std::size_t c = 0; c < _n_components; c++)
    q += (*_alpha[c])[_qp] * _emissivity[c] * _sigma *
         (Utility::pow<4>(_u[_qp]) - Utility::pow<4>((*_T_infinity[c])[_qp]));

  return _test[_i][_qp] * q;
}

Real
CoupledSimpleRadiativeHeatFluxBC::computeQpJacobian()
{
  Real dq = 0;
  for (std::size_t c = 0; c < _n_components; c++)
    dq += (*_alpha[c])[_qp] * _emissivity[c] * _sigma * 4.0 * Utility::pow<3>(_u[_qp]) *
          _phi[_j][_qp];
  return _test[_i][_qp] * dq;
}
