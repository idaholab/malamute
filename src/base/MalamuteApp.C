/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "MalamuteApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
MalamuteApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Do not use legacy material output, i.e., output properties on INITIAL as well as TIMESTEP_END
  params.set<bool>("use_legacy_material_output") = false;

  return params;
}

MalamuteApp::MalamuteApp(InputParameters parameters) : MooseApp(parameters)
{
  MalamuteApp::registerAll(_factory, _action_factory, _syntax);
}

MalamuteApp::~MalamuteApp() {}

void
MalamuteApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<MalamuteApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"MalamuteApp"});
  Registry::registerActionsTo(af, {"MalamuteApp"});

  // Adds [SpatioTemporalPath] block
  registerSyntax("EmptyAction", "SpatioTemporalPaths");
  registerSyntaxTask("AddSpatioTemporalPathAction", "SpatioTemporalPaths/*", "add_user_object");
}

void
MalamuteApp::registerApps()
{
  registerApp(MalamuteApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
MalamuteApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  MalamuteApp::registerAll(f, af, s);
}
extern "C" void
MalamuteApp__registerApps()
{
  MalamuteApp::registerApps();
}
