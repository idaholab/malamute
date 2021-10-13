#include "SurfaceTensionBC.h"
#include "Assembly.h"

registerMooseObject("BaldrApp", SurfaceTensionBC);

InputParameters
SurfaceTensionBC::validParams()
{
  InputParameters params = ADIntegratedBC::validParams();
  params.addClassDescription("Surface tension stresses.");
  params.addRequiredParam<unsigned>("component", "The velocity component");
  params.addCoupledVar("temperature", "The temperature for dependence of surface tension");
  return params;
}

SurfaceTensionBC::SurfaceTensionBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters),
    _component(getParam<unsigned>("component")),
    _surface_term_curvature(getADMaterialProperty<RealVectorValue>("surface_term_curvature")),
    _surface_term_gradient1(getADMaterialProperty<RealVectorValue>("surface_term_gradient1")),
    _surface_term_gradient2(getADMaterialProperty<RealVectorValue>("surface_term_gradient2"))
{
}

ADReal
SurfaceTensionBC::computeQpResidual()
{
  return _test[_i][_qp] *
         (_surface_term_curvature[_qp](_component) + _surface_term_gradient1[_qp](_component) +
          _surface_term_gradient2[_qp](_component));
}
