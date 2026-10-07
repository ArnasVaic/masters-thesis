#include "FixedTimeStep.h"

namespace yag_model
{

FixedTimeStep::FixedTimeStep(double const dt): dt(dt)
{

}

double FixedTimeStep::getTimestep() const
{
    return dt;
}

void FixedTimeStep::advance(SolverState const& state)
{

}

} // yag_model