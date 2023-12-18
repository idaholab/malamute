/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "MooseApp.h"

class MalamuteApp : public MooseApp
{
public:
  static InputParameters validParams();

  MalamuteApp(InputParameters parameters);
  virtual ~MalamuteApp();

  static void registerApps();
  static void registerAll(Factory & f, ActionFactory & af, Syntax & s);
};
