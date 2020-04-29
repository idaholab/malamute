#include "LevelSetCurvatureRegularization.h"

registerMooseObject("ValhallaApp", LevelSetCurvatureRegularization);

InputParameters
LevelSetCurvatureRegularization::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addClassDescription("Computes regularized interface curvature that is represented by a "
                             "level set function (Elin Olsson et.al, JCP 225 (2007) 785–807).");
  params.addRequiredCoupledVar("level_set_regularized_gradient",
                               "Vector variable of level set's regularized gradient.");
  params.addRequiredParam<Real>("epsilon", "Regulizatione parameter.");
  return params;
}

LevelSetCurvatureRegularization::LevelSetCurvatureRegularization(const InputParameters & parameters)
  : ADKernel(parameters),
    _grad_c(adCoupledVectorValue("level_set_regularized_gradient")),
    _epsilon(getParam<Real>("epsilon"))
{
}

ADReal
LevelSetCurvatureRegularization::computeQpResidual()
{
  ADReal s = (_grad_c[_qp] + RealVectorValue(libMesh::TOLERANCE)).norm();
  ADRealVectorValue n = _grad_c[_qp] / s;

  return _test[_i][_qp] * _u[_qp] - _grad_test[_i][_qp] * (n - _epsilon * _grad_u[_qp]);
}
