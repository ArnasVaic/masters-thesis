#pragma once

#include <cstddef>
#include <cstdint>
#include <vector>

namespace yag_model {

// Bit flags selecting solution channels, bit i corresponds to c[i]
enum Channel : uint32_t {
  AL2O3 = 1u << 0,
  Y2O3 = 1u << 1,
  YAM = 1u << 2,
  YAP = 1u << 3,
  YAG = 1u << 4,
  ALL = AL2O3 | Y2O3 | YAM | YAP | YAG,
};

// Indices of the channels selected by the mask, in ascending order
inline std::vector<size_t> channelIndices(uint32_t const mask) {
  std::vector<size_t> indices;
  for (size_t i = 0; i < 5; ++i) {
    if (mask & (1u << i)) {
      indices.push_back(i);
    }
  }
  return indices;
}

}  // namespace yag_model
