#pragma once

#include <memory>
#include <vector>
#include <xtensor/containers/xadapt.hpp>

namespace yag_model {

// Read-only view of consecutive captured frames. Does not copy, `owner` keeps
// the underlying storage alive for as long as the batch exists.
class ResultBatch {
public:
  ResultBatch(
      std::shared_ptr<void const> owner,
      double const* values,
      double const* times,
      std::vector<size_t> shape
  );

  // Number of frames in the batch
  [[nodiscard]]
  size_t size() const {
    return values_shape[0];
  }

  // Shape (N, frame_shape...)
  [[nodiscard]]
  std::vector<size_t> const& shape() const {
    return values_shape;
  }

  [[nodiscard]]
  auto values() const {
    return xt::adapt(values_data, valueCount(), xt::no_ownership(), values_shape);
  }

  [[nodiscard]]
  auto times() const {
    return xt::adapt(times_data, size(), xt::no_ownership(), std::vector<size_t>{size()});
  }

  [[nodiscard]]
  double const* valuesData() const {
    return values_data;
  }

  [[nodiscard]]
  double const* timesData() const {
    return times_data;
  }

  [[nodiscard]]
  std::shared_ptr<void const> const& owner() const {
    return storage_owner;
  }

private:
  std::shared_ptr<void const> storage_owner;
  double const* values_data;
  double const* times_data;
  std::vector<size_t> values_shape;

  [[nodiscard]]
  size_t valueCount() const;
};

}  // namespace yag_model
