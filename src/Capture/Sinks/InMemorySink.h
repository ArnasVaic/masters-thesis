#pragma once

#include <optional>

#include "ISink.h"
#include "Result/FrameBuffer.h"

namespace yag_model {

// Keeps frames in memory. With a capacity only the first `capacity` frames
// are stored, without one the buffer grows as needed.
class InMemorySink : public ISink {
public:
  std::optional<size_t> capacity;

  explicit InMemorySink(std::optional<size_t> capacity = std::nullopt);

  void begin(ResultMetadata const& metadata) override;

  void write(xt::xarray<double> const& frame, double t) override;

  std::shared_ptr<IResult> finish() override;

private:
  std::optional<ResultMetadata> metadata;
  std::shared_ptr<FrameBuffer> buffer;
  size_t frame_size = 0;
};

}  // namespace yag_model
