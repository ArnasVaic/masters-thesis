#pragma once

#include <highfive/H5DataSet.hpp>
#include <highfive/H5File.hpp>
#include <string>

#include "Result/IResult.h"

namespace yag_model {

// Reads a result file written by HDF5Sink. Batches are read from disk on
// demand, the file stays open for the lifetime of the result.
class HDF5Result : public IResult {
public:
  explicit HDF5Result(std::string const& path);

  [[nodiscard]]
  ResultMetadata const& metadata() const override;

  [[nodiscard]]
  size_t size() const override;

  [[nodiscard]]
  ResultBatch read(size_t begin, size_t end) const override;

private:
  HighFive::File file;
  HighFive::DataSet values;
  HighFive::DataSet times;
  ResultMetadata meta;
  size_t frame_size;
  size_t frames;
};

}  // namespace yag_model
