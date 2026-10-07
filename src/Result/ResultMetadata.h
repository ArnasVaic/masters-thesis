#pragma once

#include <cstdint>
#include <string>
#include <vector>

#include "Config/Discretization.h"

namespace yag_model {

// Describes what a result holds, shared by sinks and results
struct ResultMetadata {
  // Shape of a single captured frame, as produced by the reducer
  std::vector<size_t> frame_shape;

  // Channel bit mask, see Channel
  uint32_t channels;

  // Name of the reducer that produced the frames
  std::string reducer;

  Discretization discretization;
};

}  // namespace yag_model
