/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2024, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "MalamuteTestApp.h"
#include "MooseMain.h"

// Begin the main program.
int
main(int argc, char * argv[])
{
  return Moose::main<MalamuteTestApp>(argc, argv);
}
