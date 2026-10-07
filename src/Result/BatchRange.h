#pragma once

#include <cstddef>

#include "Result/ResultBatch.h"

namespace yag_model {

class IResult;

// Iterable over a result in batches of at most batch_size frames.
// The range refers to the result, which must outlive it.
class BatchRange {
public:
  class Iterator {
  public:
    using value_type = ResultBatch;
    using difference_type = std::ptrdiff_t;

    Iterator() = default;
    Iterator(IResult const* result, size_t pos, size_t batch_size);

    ResultBatch operator*() const;
    Iterator& operator++();
    void operator++(int);
    bool operator==(Iterator const& other) const;

  private:
    IResult const* result = nullptr;
    size_t pos = 0;
    size_t batch_size = 0;
  };

  BatchRange(IResult const& result, size_t batch_size);

  [[nodiscard]]
  Iterator begin() const;

  [[nodiscard]]
  Iterator end() const;

  // Number of batches
  [[nodiscard]]
  size_t size() const;

private:
  IResult const& result;
  size_t batch_size;
};

}  // namespace yag_model
