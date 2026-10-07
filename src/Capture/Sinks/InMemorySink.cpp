#include "InMemorySink.h"

#include <functional>
#include <numeric>
#include <stdexcept>
#include <utility>

#include "Result/InMemoryResult.h"

namespace yag_model {

InMemorySink::InMemorySink(std::optional<size_t> const capacity) : capacity(capacity) {}

void InMemorySink::begin(ResultMetadata const& meta) {
  metadata = meta;
  frame_size = std::accumulate(
      meta.frame_shape.begin(), meta.frame_shape.end(), size_t{1}, std::multiplies<>()
  );

  // Previous results keep their own buffer, start a new one
  buffer = std::make_shared<FrameBuffer>();

  if (capacity) {
    buffer->values.reserve(*capacity * frame_size);
    buffer->times.reserve(*capacity);
  }
}

void InMemorySink::write(xt::xarray<double> const& frame, double const t) {
  if (!buffer) {
    throw std::logic_error("InMemorySink::write called outside begin()/finish()");
  }

  if (frame.size() != frame_size) {
    throw std::invalid_argument("Frame size does not match the declared frame shape");
  }

  if (capacity && buffer->times.size() >= *capacity) {
    return;
  }

  buffer->values.insert(buffer->values.end(), frame.data(), frame.data() + frame.size());
  buffer->times.push_back(t);
}

std::shared_ptr<IResult> InMemorySink::finish() {
  if (!buffer) {
    throw std::logic_error("InMemorySink::finish called without begin()");
  }

  return std::make_shared<InMemoryResult>(*metadata, std::exchange(buffer, nullptr));
}

}  // namespace yag_model
