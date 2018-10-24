//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "ArticunoTestApp.h"
#include "ArticunoApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

template <>
InputParameters
validParams<ArticunoTestApp>()
{
  InputParameters params = validParams<ArticunoApp>();
  return params;
}

ArticunoTestApp::ArticunoTestApp(InputParameters parameters) : MooseApp(parameters)
{
  ArticunoTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

ArticunoTestApp::~ArticunoTestApp() {}

void
ArticunoTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  ArticunoApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"ArticunoTestApp"});
    Registry::registerActionsTo(af, {"ArticunoTestApp"});
  }
}

void
ArticunoTestApp::registerApps()
{
  registerApp(ArticunoApp);
  registerApp(ArticunoTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
ArticunoTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ArticunoTestApp::registerAll(f, af, s);
}
extern "C" void
ArticunoTestApp__registerApps()
{
  ArticunoTestApp::registerApps();
}
