//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "SurfaceTensionBC.h"
#include "Assembly.h"

registerADMooseObject("LaserWeldingApp", SurfaceTensionBC);

defineADValidParams(
    SurfaceTensionBC, ADIntegratedBC, params.addClassDescription("Surface tension stresses.");
    params.addRequiredParam<unsigned>("component", "The velocity component");
    params.addCoupledVar("temperature", "The temperature for dependence of surface tension"););

template <ComputeStage compute_stage>
SurfaceTensionBC<compute_stage>::SurfaceTensionBC(const InputParameters & parameters)
  : ADIntegratedBC<compute_stage>(parameters),
    _component(adGetParam<unsigned>("component")),
    _surface_term_curvature(adGetADMaterialProperty<RealVectorValue>("surface_term_curvature")),
    _surface_term_gradient1(adGetADMaterialProperty<RealVectorValue>("surface_term_gradient1")),
    _surface_term_gradient2(adGetADMaterialProperty<RealVectorValue>("surface_term_gradient2"))
{
}

template <ComputeStage compute_stage>
ADResidual
SurfaceTensionBC<compute_stage>::computeQpResidual()
{
  return _test[_i][_qp] *
         (_surface_term_curvature[_qp](_component) + _surface_term_gradient1[_qp](_component) +
          _surface_term_gradient2[_qp](_component));
}
