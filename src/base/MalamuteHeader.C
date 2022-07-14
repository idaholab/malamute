/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2022, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "MalamuteHeader.h"
#include <sstream>

namespace MalamuteHeader
{
std::string
header()
{
  std::stringstream header;
  header << "\n\n"
         << "M     M      A      L            A      M     M  U     U  T T T T  E E E E \n"
         << "MM   MM     A A     L           A A     MM   MM  U     U     T     E       \n"
         << "M M M M    A   A    L          A   A    M M M M  U     U     T     E E E E \n"
         << "M  M  M   A A A A   L         A A A A   M  M  M  U     U     T     E       \n"
         << "M     M  A       A  L L L L  A       A  M     M   U U U      T     E E E E \n"
         << "\n\n"
         << "MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs \n"
         << "\n\n"
         << "Copyright 2021 - 2022, Battelle Energy Alliance, LLC \n"
         << "ALL RIGHTS RESERVED \n"
         << "\n\n"
         << "NOTICE: These data were produced by BATTELLE ENERGY ALLIANCE, LLC under Contract \n"
         << "No. DE-AC07-05ID14517 with the Department of Energy. For ten(10) years from \n"
         << "July 8, 2021, the Government is granted for itself and others acting on its behalf \n"
         << "a nonexclusive, paid-up, irrevocable worldwide license in this data to reproduce, \n"
         << "prepare derivative works, and perform publicly and display publicly, by or on \n"
         << "behalf of the Government. There is provision for the possible extension of the \n"
         << "term of this license. Subsequent to that period or any extension granted, the \n"
         << "Government is granted for itself and others acting on its behalf a nonexclusive, \n"
         << "paid-up, irrevocable worldwide license in this data to reproduce, prepare \n"
         << "derivative works, distribute copies to the public, perform publicly and display \n"
         << "publicly, and to permit others to do so. The specific term of the license can be \n"
         << "identified by inquiry made to Contractor or DOE. NEITHER THE UNITED STATES NOR \n"
         << "THE UNITED STATES DEPARTMENT OF ENERGY, NOR ANY OF THEIR EMPLOYEES, MAKES ANY \n"
         << "WARRANTY, EXPRESS OR IMPLIED, OR ASSUMES ANY LEGAL LIABILITY OR RESPONSIBILITY \n"
         << "FOR THE ACCURACY, COMPLETENESS, OR USEFULNESS OF ANY DATA, APPARATUS, PRODUCT, \n"
         << "OR PROCESS DISCLOSED, OR REPRESENTS THAT ITS USE WOULD NOT INFRINGE PRIVATELY \n"
         << "OWNED RIGHTS. \n"
         << "\n\n";
  return header.str();
}
} // namespace MalamuteHeader
