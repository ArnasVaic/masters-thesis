#include "Result/InMemoryResult.h"

#include <functional>
#include <numeric>
#include <stdexcept>

namespace yag_model {

InMemoryResult::InMemoryResult(ResultMetadata metadata, std::shared_ptr<FrameBuffer const> buffer)
    : meta(std::move(metadata)),
      buffer(std::move(buffer)),
      frame_size(
          std::accumulate(
              meta.frame_shape.begin(), meta.frame_shape.end(), size_t{1}, std::multiplies<>()
          )
      ) {}

ResultMetadata const& InMemoryResult::metadata() const {
  return meta;
}

size_t InMemoryResult::size() const {
  return buffer->times.size();
}

ResultBatch InMemoryResult::read(size_t const begin, size_t const end) const {
  if (begin > end || end > size()) {
    throw std::out_of_range("Frame range out of bounds");
  }

  std::vector<size_t> shape{end - begin};
  shape.insert(shape.end(), meta.frame_shape.begin(), meta.frame_shape.end());

  return {
      buffer,
      buffer->values.data() + begin * frame_size,
      buffer->times.data() + begin,
      std::move(shape)
  };
}

}  // namespace yag_model
