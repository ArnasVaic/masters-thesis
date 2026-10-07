#include "Result/ResultBatch.h"

#include <functional>
#include <numeric>

namespace yag_model {

ResultBatch::ResultBatch(
    std::shared_ptr<void const> owner,
    double const* values,
    double const* times,
    std::vector<size_t> shape
)
    : storage_owner(std::move(owner)),
      values_data(values),
      times_data(times),
      values_shape(std::move(shape)) {}

size_t ResultBatch::valueCount() const {
  return std::accumulate(values_shape.begin(), values_shape.end(), size_t{1}, std::multiplies<>());
}

}  // namespace yag_model
