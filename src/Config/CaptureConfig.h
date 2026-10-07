#pragma once

#include <memory>

#include "Capture/Reducers/ConcentrationFieldReducer.h"
#include "Capture/Reducers/IReducer.h"
#include "Capture/Sinks/ISink.h"
#include "Capture/Sinks/InMemorySink.h"
#include "Capture/Triggers/ITrigger.h"
#include "Capture/Triggers/StrideTrigger.h"
#include "Core/Channel.h"

namespace yag_model {

// What to capture (channels, reducer), when (trigger) and where to (sink)
struct CaptureConfig {
  uint32_t channels = ALL;
  std::shared_ptr<IReducer> reducer = std::make_shared<ConcentrationFieldReducer>();
  std::shared_ptr<ITrigger> trigger = std::make_shared<StrideTrigger>(1);
  std::shared_ptr<ISink> sink = std::make_shared<InMemorySink>();
};

}  // namespace yag_model
