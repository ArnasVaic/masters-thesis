#pragma once

#include <memory>

#include "Result/FrameBuffer.h"
#include "Result/IResult.h"

namespace yag_model {

class InMemoryResult : public IResult {
public:
  InMemoryResult(ResultMetadata metadata, std::shared_ptr<FrameBuffer const> buffer);

  [[nodiscard]]
  ResultMetadata const& metadata() const override;

  [[nodiscard]]
  size_t size() const override;

  [[nodiscard]]
  ResultBatch read(size_t begin, size_t end) const override;

private:
  ResultMetadata meta;
  std::shared_ptr<FrameBuffer const> buffer;
  size_t frame_size;
};

}  // namespace yag_model
