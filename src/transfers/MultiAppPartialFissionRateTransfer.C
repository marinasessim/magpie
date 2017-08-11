#include "MultiAppPartialFissionRateTransfer.h"
#include "MultiApp.h"
#include "FEProblem.h"
#include "MooseTypes.h"
#include "MultiIndex.h"
#include "UserObject.h"
#include "MooseParsedFunctionBase.h"


template<>
InputParameters validParams<MultiAppPartialFissionRateTransfer>()
{
  InputParameters params = validParams<MultiAppTransfer>();
  params.addRequiredParam<FunctionName>("partial_fission_rate", "Partial fission rate function name.");
  return params;
}

MultiAppPartialFissionRateTransfer::MultiAppPartialFissionRateTransfer(const InputParameters & parameters) :
    MultiAppTransfer(parameters),
    _partial_fission_rate_name(getParam<FunctionName>("partial_fission_rate"))
{
  if (_direction != TO_MULTIAPP)
    mooseError("MultiAppPartialFissionRateTransfer can only send data from a neutronics master app to a mesoscale multiapp.");
}

void
MultiAppPartialFissionRateTransfer::execute()
{
  // get the partial fission rate function
  FEProblem & from_problem = _multi_app->problem();
  const MooseParsedFunctionBase & partial_fission_rate = from_problem.getFunction<MooseParsedFunctionBase>(_partial_fission_rate_name);

// Questions:
// This gets the UO from the base class. how do I do if it is a parsed function in the input file?
// Other option is to do the entire calculation on the c file, but I'll have to read class and uo from the master app. How do I do that?
}
