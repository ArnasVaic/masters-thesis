#pragma once

#include "Result/BatchRange.h"
#include "Result/ResultBatch.h"
#include "Result/ResultMetadata.h"

namespace yag_model {

class IResult {
public:
  virtual ~IResult() = default;

  [[nodiscard]]
  virtual ResultMetadata const& metadata() const = 0;

  // Number of captured frames
  [[nodiscard]]
  virtual size_t size() const = 0;

  // Frames [begin, end)
  [[nodiscard]]
  virtual ResultBatch read(size_t begin, size_t end) const = 0;

  [[nodiscard]]
  ResultBatch all() const {
    return read(0, size());
  }

  [[nodiscard]]
  BatchRange batches(size_t const batch_size) const {
    return {*this, batch_size};
  }
};

}  // namespace yag_model
