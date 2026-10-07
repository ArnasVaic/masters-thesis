#include "HDF5Sink.h"

#include <algorithm>
#include <functional>
#include <highfive/H5Utility.hpp>
#include <numeric>
#include <stdexcept>

#include "Result/HDF5Format.h"
#include "Result/HDF5Result.h"

namespace yag_model {

HDF5Sink::HDF5Sink(std::string path) : path(std::move(path)) {}

void HDF5Sink::begin(ResultMetadata const& metadata) {
  namespace fmt = hdf5_format;

  // Drop handles of a run that never finished
  values.reset();
  times.reset();
  file.reset();

  try {
    // Errors are rethrown below, keep HDF5 from also printing its error stack
    HighFive::SilenceHDF5 const silence;
    file.emplace(path, HighFive::File::Overwrite);
  } catch (HighFive::Exception const& e) {
    throw std::runtime_error(
        "Cannot create HDF5 file '" + path +
        "', it may still be open by a result: " + std::string(e.what())
    );
  }

  frame_shape = metadata.frame_shape;
  frame_size =
      std::accumulate(frame_shape.begin(), frame_shape.end(), size_t{1}, std::multiplies<>());
  frames = 0;

  std::vector<size_t> dims{0};
  std::vector<size_t> max_dims{HighFive::DataSpace::UNLIMITED};
  std::vector<hsize_t> chunk{std::max<size_t>(1, fmt::chunk_bytes / (frame_size * sizeof(double)))};
  for (size_t const d : frame_shape) {
    dims.push_back(d);
    max_dims.push_back(d);
    chunk.push_back(d);
  }

  HighFive::DataSetCreateProps values_props;
  values_props.add(HighFive::Chunking(chunk));
  values.emplace(
      file->createDataSet<double>(fmt::values, HighFive::DataSpace(dims, max_dims), values_props)
  );

  HighFive::DataSetCreateProps times_props;
  times_props.add(HighFive::Chunking(std::vector<hsize_t>{fmt::times_chunk}));
  times.emplace(file->createDataSet<double>(
      fmt::times, HighFive::DataSpace({0}, {HighFive::DataSpace::UNLIMITED}), times_props
  ));

  Discretization const& disc = metadata.discretization;
  file->createAttribute(fmt::format_version_attr, fmt::version);
  file->createAttribute(fmt::channels_attr, metadata.channels);
  file->createAttribute(fmt::reducer_attr, metadata.reducer);
  file->createAttribute(
      fmt::mesh_resolution_attr, std::vector<size_t>{disc.mesh_res_x, disc.mesh_res_y}
  );
  file->createAttribute(
      fmt::physical_size_attr, std::vector<double>{disc.physical_space_w, disc.physical_space_h}
  );
}

void HDF5Sink::write(xt::xarray<double> const& frame, double const t) {
  if (!file) {
    throw std::logic_error("HDF5Sink::write called outside begin()/finish()");
  }

  if (frame.size() != frame_size) {
    throw std::invalid_argument("Frame size does not match the declared frame shape");
  }

  std::vector<size_t> offset{frames};
  std::vector<size_t> count{1};
  std::vector<size_t> dims{frames + 1};
  for (size_t const d : frame_shape) {
    offset.push_back(0);
    count.push_back(d);
    dims.push_back(d);
  }

  values->resize(dims);
  values->select(offset, count).write_raw(frame.data());

  times->resize({frames + 1});
  times->select({frames}, {1}).write_raw(&t);

  frames++;
}

std::shared_ptr<IResult> HDF5Sink::finish() {
  if (!file) {
    throw std::logic_error("HDF5Sink::finish called without begin()");
  }

  // Close the writer before the result reopens the file read-only
  values.reset();
  times.reset();
  file->flush();
  file.reset();

  return std::make_shared<HDF5Result>(path);
}

}  // namespace yag_model
