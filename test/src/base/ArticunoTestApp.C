//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "BaldrTestApp.h"
#include "BaldrApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

template <>
InputParameters
validParams<BaldrTestApp>()
{
  InputParameters params = validParams<BaldrApp>();
  return params;
}

BaldrTestApp::BaldrTestApp(InputParameters parameters) : MooseApp(parameters)
{
  BaldrTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

BaldrTestApp::~BaldrTestApp() {}

void
BaldrTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  BaldrApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"BaldrTestApp"});
    Registry::registerActionsTo(af, {"BaldrTestApp"});
  }
}

void
BaldrTestApp::registerApps()
{
  registerApp(BaldrApp);
  registerApp(BaldrTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
BaldrTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  BaldrTestApp::registerAll(f, af, s);
}
extern "C" void
BaldrTestApp__registerApps()
{
  BaldrTestApp::registerApps();
}
