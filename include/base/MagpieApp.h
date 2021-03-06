#ifndef MAGPIEAPP_H
#define MAGPIEAPP_H

#include "MooseApp.h"

class MagpieApp;

template<>
InputParameters validParams<MagpieApp>();

class MagpieApp : public MooseApp
{
public:
  MagpieApp(const InputParameters & parameters);
  virtual ~MagpieApp();

  static void registerApps();
  static void registerObjects(Factory & factory);
  static void associateSyntax(Syntax & syntax, ActionFactory & action_factory);

  static void printLogo();
};

#endif /* MAGPIEAPP_H */
