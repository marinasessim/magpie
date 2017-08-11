#ifndef MULTIAPPPARTIALFISSIONRATETRANSFER_H
#define MULTIAPPPARTIALFISSIONRATETRANSFER_H

#include "MultiAppTransfer.h"

class MultiAppPartialFissionRateTransfer;

template<>
InputParameters validParams<MultiAppPartialFissionRateTransfer>();

/**
 * Transfer partial fission rates to a neutronics based pka generator.
 */
class MultiAppPartialFissionRateTransfer : public MultiAppTransfer
{
public:
  MultiAppPartialFissionRateTransfer(const InputParameters & parameters);

  virtual void execute();

protected:
  FunctionName _partial_fission_rate_name;
};

#endif //MULTIAPPPARTIALFISSIONRATETRANSFER_H
