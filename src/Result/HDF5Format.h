#pragma once

#include <cstddef>
#include <cstdint>

// Layout of HDF5 result files, shared by HDF5Sink (writer) and HDF5Result (reader).
//
//   /values  (N, frame_shape...)  double, extendable along N
//   /times   (N,)                 double, extendable along N
//
// Root attributes: format_version, channels, reducer, mesh_resolution [nx, ny],
// physical_size [w, h]
namespace yag_model::hdf5_format {

inline constexpr uint32_t version = 1;

inline constexpr char const* values = "values";
inline constexpr char const* times = "times";

inline constexpr char const* format_version_attr = "format_version";
inline constexpr char const* channels_attr = "channels";
inline constexpr char const* reducer_attr = "reducer";
inline constexpr char const* mesh_resolution_attr = "mesh_resolution";
inline constexpr char const* physical_size_attr = "physical_size";

// Target size of a /values chunk, a chunk always holds at least one frame
inline constexpr size_t chunk_bytes = 256 * 1024;

inline constexpr size_t times_chunk = 4096;

}  // namespace yag_model::hdf5_format
