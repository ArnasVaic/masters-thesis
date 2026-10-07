#include "Result/BatchRange.h"

#include <algorithm>
#include <stdexcept>

#include "Result/IResult.h"

namespace yag_model {

BatchRange::Iterator::Iterator(IResult const* result, size_t const pos, size_t const batch_size)
    : result(result), pos(pos), batch_size(batch_size) {}

ResultBatch BatchRange::Iterator::operator*() const {
  return result->read(pos, std::min(pos + batch_size, result->size()));
}

BatchRange::Iterator& BatchRange::Iterator::operator++() {
  pos = std::min(pos + batch_size, result->size());
  return *this;
}

void BatchRange::Iterator::operator++(int) {
  ++*this;
}

bool BatchRange::Iterator::operator==(Iterator const& other) const {
  return pos == other.pos;
}

BatchRange::BatchRange(IResult const& result, size_t const batch_size)
    : result(result), batch_size(batch_size) {
  if (batch_size == 0) {
    throw std::invalid_argument("batch_size must be positive");
  }
}

BatchRange::Iterator BatchRange::begin() const {
  return {&result, 0, batch_size};
}

BatchRange::Iterator BatchRange::end() const {
  return {&result, result.size(), batch_size};
}

size_t BatchRange::size() const {
  return (result.size() + batch_size - 1) / batch_size;
}

}  // namespace yag_model
