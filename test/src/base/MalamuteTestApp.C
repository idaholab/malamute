/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2025, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "MalamuteTestApp.h"
#include "MalamuteApp.h"
#include "MalamuteHeader.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
MalamuteTestApp::validParams()
{
  InputParameters params = MalamuteApp::validParams();
  return params;
}

MalamuteTestApp::MalamuteTestApp(const InputParameters & parameters) : MooseApp(parameters)
{
  MalamuteTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

MalamuteTestApp::~MalamuteTestApp() {}

std::string
MalamuteTestApp::header() const
{
  return MalamuteHeader::header();
}

void
MalamuteTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  MalamuteApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"MalamuteTestApp"});
    Registry::registerActionsTo(af, {"MalamuteTestApp"});
  }
}

void
MalamuteTestApp::registerApps()
{
  MalamuteApp::registerApps();
  registerApp(MalamuteTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
MalamuteTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  MalamuteTestApp::registerAll(f, af, s);
}
extern "C" void
MalamuteTestApp__registerApps()
{
  MalamuteTestApp::registerApps();
}
