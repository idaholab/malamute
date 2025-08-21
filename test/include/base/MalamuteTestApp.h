/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2025, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "MooseApp.h"

class MalamuteTestApp : public MooseApp
{
public:
  static InputParameters validParams();

  MalamuteTestApp(const InputParameters & parameters);
  virtual ~MalamuteTestApp();

  /// Display the Malamute copyright notice and header information
  virtual std::string header() const override;

  static void registerApps();
  static void registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs = false);
};
