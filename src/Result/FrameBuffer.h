#pragma once

#include <vector>

namespace yag_model {

// Contiguous frame-first storage: frame n occupies values[n * frame_size, (n + 1) * frame_size)
struct FrameBuffer {
  std::vector<double> values;
  std::vector<double> times;
};

}  // namespace yag_model
