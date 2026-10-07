#pragma once

#include <memory>
#include <xtensor/containers/xarray.hpp>

#include "Result/IResult.h"
#include "Result/ResultMetadata.h"

namespace yag_model {

// Stores captured frames during a solve and hands them over as a result.
// A sink can be reused: every begin() starts a fresh result.
class ISink {
public:
  virtual ~ISink() = default;

  // Called once before the first write
  virtual void begin(ResultMetadata const& metadata) = 0;

  // Frame shape matches metadata.frame_shape
  virtual void write(xt::xarray<double> const& frame, double t) = 0;

  // Called once after the last write
  virtual std::shared_ptr<IResult> finish() = 0;
};

}  // namespace yag_model
