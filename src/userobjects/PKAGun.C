#include "PKAGun.h"

template<>
InputParameters validParams<PKAGun>()
{
  InputParameters params = validParams<PKAFixedPointGenerator>();
  params.addClassDescription("This PKAGenerator starts particle from a fixed point in a fixed direction.");
  params.addRequiredParam<Point>("direction", "The fixed direction the PKAs move along");
  return params;
}

PKAGun::PKAGun(const InputParameters & parameters) :
    PKAFixedPointGenerator(parameters),
    _direction(getParam<Point>("direction"))
{
}

void
PKAGun::setDirection(MyTRIM_NS::IonBase & ion) const
{
  ion._dir = _direction;
}
