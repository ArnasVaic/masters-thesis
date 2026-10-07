#pragma once

#include <highfive/H5DataSet.hpp>
#include <highfive/H5File.hpp>
#include <optional>
#include <string>

#include "ISink.h"

namespace yag_model {

// Streams frames into an HDF5 file, see Result/HDF5Format.h for the layout.
// Every begin() overwrites the file.
class HDF5Sink : public ISink {
public:
  std::string path;

  explicit HDF5Sink(std::string path);

  void begin(ResultMetadata const& metadata) override;

  void write(xt::xarray<double> const& frame, double t) override;

  std::shared_ptr<IResult> finish() override;

private:
  std::optional<HighFive::File> file;
  std::optional<HighFive::DataSet> values;
  std::optional<HighFive::DataSet> times;
  std::vector<size_t> frame_shape;
  size_t frame_size = 0;
  size_t frames = 0;
};

}  // namespace yag_model
