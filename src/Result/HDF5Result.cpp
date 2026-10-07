#include "Result/HDF5Result.h"

#include <functional>
#include <highfive/H5Utility.hpp>
#include <numeric>
#include <optional>
#include <stdexcept>

#include "Result/FrameBuffer.h"
#include "Result/HDF5Format.h"

namespace yag_model {

namespace {

HighFive::File openChecked(std::string const& path) {
  namespace fmt = hdf5_format;

  std::optional<HighFive::File> file;

  try {
    // Errors are rethrown below, keep HDF5 from also printing its error stack
    HighFive::SilenceHDF5 const silence;
    file.emplace(path, HighFive::File::ReadOnly);
  } catch (HighFive::Exception const& e) {
    throw std::runtime_error("Cannot open HDF5 file '" + path + "': " + std::string(e.what()));
  }

  if (!file->hasAttribute(fmt::format_version_attr) ||
      file->getAttribute(fmt::format_version_attr).read<uint32_t>() != fmt::version) {
    throw std::runtime_error("'" + path + "' is not a supported yag_model result file");
  }

  return *std::move(file);
}

ResultMetadata readMetadata(HighFive::File const& file, HighFive::DataSet const& values) {
  namespace fmt = hdf5_format;

  auto const mesh = file.getAttribute(fmt::mesh_resolution_attr).read<std::vector<size_t>>();
  auto const size = file.getAttribute(fmt::physical_size_attr).read<std::vector<double>>();

  std::vector<size_t> const dims = values.getDimensions();

  return {
      .frame_shape = std::vector<size_t>(dims.begin() + 1, dims.end()),
      .channels = file.getAttribute(fmt::channels_attr).read<uint32_t>(),
      .reducer = file.getAttribute(fmt::reducer_attr).read<std::string>(),
      .discretization = Discretization(size.at(0), size.at(1), mesh.at(0), mesh.at(1)),
  };
}

}  // namespace

HDF5Result::HDF5Result(std::string const& path)
    : file(openChecked(path)),
      values(file.getDataSet(hdf5_format::values)),
      times(file.getDataSet(hdf5_format::times)),
      meta(readMetadata(file, values)),
      frame_size(
          std::accumulate(
              meta.frame_shape.begin(), meta.frame_shape.end(), size_t{1}, std::multiplies<>()
          )
      ),
      frames(times.getDimensions().at(0)) {}

ResultMetadata const& HDF5Result::metadata() const {
  return meta;
}

size_t HDF5Result::size() const {
  return frames;
}

ResultBatch HDF5Result::read(size_t const begin, size_t const end) const {
  if (begin > end || end > size()) {
    throw std::out_of_range("Frame range out of bounds");
  }

  size_t const n = end - begin;

  auto buffer = std::make_shared<FrameBuffer>();
  buffer->values.resize(n * frame_size);
  buffer->times.resize(n);

  std::vector<size_t> shape{n};
  shape.insert(shape.end(), meta.frame_shape.begin(), meta.frame_shape.end());

  if (n > 0) {
    std::vector<size_t> offset(shape.size(), 0);
    offset[0] = begin;

    values.select(offset, shape).read_raw(buffer->values.data());
    times.select({begin}, {n}).read_raw(buffer->times.data());
  }

  double const* const values_data = buffer->values.data();
  double const* const times_data = buffer->times.data();

  return {std::move(buffer), values_data, times_data, std::move(shape)};
}

}  // namespace yag_model
