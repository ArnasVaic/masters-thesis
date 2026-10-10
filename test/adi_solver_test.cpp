#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <cmath>
#include <numbers>
#include <random>
#include <xtensor-blas/xlinalg.hpp>
#include <xtensor/views/xview.hpp>

#include "Brakes/FixedStepBrake.h"
#include "Capture/Reducers/ConcentrationFieldReducer.h"
#include "Capture/Reducers/TotalMassReducer.h"
#include "Capture/Triggers/LastFrameTrigger.h"
#include "Capture/Triggers/StrideTrigger.h"
#include "Core/Constants.h"
#include "Core/TridiagonalLU.h"
#include "Solver/ADISolver.h"
#include "TimeStep/FixedTimeStep.h"
#include "TimeStep/GeometricTimeStep.h"

namespace ym = yag_model;

namespace {

// Non-square with dx != dy so a mix-up of the sweep directions or a transposed field shows up
ym::Discretization const disc(1.5, 1.0, 23, 17);
size_t const H = disc.mesh_res_y;
size_t const W = disc.mesh_res_x;

ym::SolverConfig config(std::shared_ptr<ym::ITimeStep> step, size_t const steps) {
  ym::SolverConfig config;
  config.discretization = disc;
  config.step = std::move(step);
  config.brake = std::make_shared<ym::FixedStepBrake>(steps);
  config.capture.reducer = std::make_shared<ym::ConcentrationFieldReducer>();
  config.capture.trigger = std::make_shared<ym::LastFrameTrigger>();
  return config;
}

// Final concentration fields of a solve
ym::SolutionState solveFields(
    ym::SolverConfig const& config, ym::SolutionState const& ic, ym::ModelParameters const& params
) {
  auto const result = ym::solve(config, ic, params);
  REQUIRE(result->size() == 1);

  auto const values = result->all().values();
  ym::SolutionState out(H, W);
  for (size_t m = 0; m < out.c.size(); ++m) {
    out.c[m] = xt::view(values, 0, m);
  }
  return out;
}

ym::SolutionState randomState(std::mt19937& rng) {
  std::uniform_real_distribution<double> reagent(0.0, 5.0);
  std::uniform_real_distribution<double> product(0.0, 1.0);

  ym::SolutionState s(H, W);
  for (size_t m = 0; m < s.c.size(); ++m) {
    for (auto& v : s.c[m]) {
      v = m < 2 ? reagent(rng) : product(rng);
    }
  }
  return s;
}

double maxAbsDiff(xt::xarray<double> const& a, xt::xarray<double> const& b) {
  REQUIRE(a.shape() == b.shape());
  return xt::amax(xt::abs(a - b))();
}

// The previous implementation, kept as a reference: one LAPACK dgttrs solve per line, with the
// right-hand sides in column-major buffers and fields indexed through xtensor
ym::SolutionState referenceSolve(
    ym::SolutionState c, ym::ModelParameters const& params, std::vector<double> const& dts
) {
  ym::SolutionState half(H, W);
  xt::xarray<double> const& S = ym::Constants::S;

  auto const sweepLU = [](size_t const n, double const mu) {
    ym::TridiagonalLU lu(n);
    std::ranges::fill(lu.dl, -mu);
    std::ranges::fill(lu.d, 1 + 2 * mu);
    lu.d.front() = 1 + mu;
    lu.d.back() = 1 + mu;
    std::ranges::fill(lu.du, -mu);
    lu.factor();
    return lu;
  };

  for (double const dt : dts) {
    xt::xarray<double> const R = 0.5 * dt * xt::linalg::dot(S, xt::diag(params.k));
    xt::xarray<double> const mu_x = 0.5 * dt * params.D / (disc.dx * disc.dx);
    xt::xarray<double> const mu_y = 0.5 * dt * params.D / (disc.dy * disc.dy);

    auto const reaction = [&](ym::SolutionState const& s, size_t const m, size_t r, size_t col) {
      return s.c[0](r, col) *
             (R(m, 0) * s.c[1](r, col) + R(m, 1) * s.c[2](r, col) + R(m, 2) * s.c[3](r, col));
    };

    // x sweep: implicit along x, line r is column r of a column-major (W x H) buffer
    for (size_t m = 0; m < 5; ++m) {
      std::vector<double> B(W * H);
      for (size_t r = 0; r < H; ++r) {
        size_t const top = std::min(r + 1, H - 1);
        size_t const bot = r == 0 ? 0 : r - 1;
        for (size_t col = 0; col < W; ++col) {
          B[r * W + col] = (1 - 2 * mu_y(m)) * c.c[m](r, col) +
                           mu_y(m) * (c.c[m](top, col) + c.c[m](bot, col)) + reaction(c, m, r, col);
        }
      }
      sweepLU(W, mu_x(m)).solve(static_cast<int>(H), B.data());
      for (size_t r = 0; r < H; ++r) {
        for (size_t col = 0; col < W; ++col) {
          half.c[m](r, col) = B[r * W + col];
        }
      }
    }

    // y sweep: implicit along y, line col is column col of a column-major (H x W) buffer
    for (size_t m = 0; m < 5; ++m) {
      std::vector<double> B(H * W);
      for (size_t col = 0; col < W; ++col) {
        size_t const right = std::min(col + 1, W - 1);
        size_t const left = col == 0 ? 0 : col - 1;
        for (size_t r = 0; r < H; ++r) {
          B[col * H + r] = (1 - 2 * mu_x(m)) * half.c[m](r, col) +
                           mu_x(m) * (half.c[m](r, left) + half.c[m](r, right)) +
                           reaction(half, m, r, col);
        }
      }
      sweepLU(H, mu_y(m)).solve(static_cast<int>(W), B.data());
      for (size_t r = 0; r < H; ++r) {
        for (size_t col = 0; col < W; ++col) {
          c.c[m](r, col) = B[col * H + r];
        }
      }
    }
  }

  return c;
}

// Discrete Neumann cosine mode k along a line of n cells, cos(pi k (j + 1/2) / n). It is an
// eigenvector of the sweep operator L with eigenvalue -lambda, lambda = 4 sin^2(pi k / (2 n))
double mode(size_t const k, size_t const n, size_t const j) {
  return std::cos(std::numbers::pi * k * (j + 0.5) / n);
}

double lambda(size_t const k, size_t const n) {
  double const s = std::sin(std::numbers::pi * k / (2.0 * n));
  return 4 * s * s;
}

}  // namespace

TEST_CASE("ADI solver: diffusion of a cosine mode matches the exact discrete decay", "[adi]") {
  // Reaction off. A product of cosine modes stays a product of the same modes and is scaled by
  //   g = (1 - mu_y ly) / (1 + mu_x lx) * (1 - mu_x lx) / (1 + mu_y ly)
  // per step (x half step, then y half step). kx = 0 or ky = 0 tests a single direction.
  auto const [kx, ky] = GENERATE(
      std::pair<size_t, size_t>{1, 0},
      std::pair<size_t, size_t>{3, 0},
      std::pair<size_t, size_t>{0, 2},
      std::pair<size_t, size_t>{2, 1},
      std::pair<size_t, size_t>{W - 1, H - 1}
  );

  double const dt = 1e-3;
  size_t const steps = 200;
  // Different per species, up to very stiff (mu ~ 50) where g is negative
  ym::ModelParameters const params({0.5, 1.0, 2.0, 50.0, 1000.0}, {0.0, 0.0, 0.0});

  ym::SolutionState ic(H, W);
  for (size_t m = 0; m < 5; ++m) {
    for (size_t r = 0; r < H; ++r) {
      for (size_t col = 0; col < W; ++col) {
        ic.c[m](r, col) = 1.0 + 0.5 * mode(kx, W, col) * mode(ky, H, r);
      }
    }
  }

  auto const out = solveFields(config(std::make_shared<ym::FixedTimeStep>(dt), steps), ic, params);

  for (size_t m = 0; m < 5; ++m) {
    double const mu_x = 0.5 * dt * params.D(m) / (disc.dx * disc.dx);
    double const mu_y = 0.5 * dt * params.D(m) / (disc.dy * disc.dy);
    double const lx = lambda(kx, W);
    double const ly = lambda(ky, H);
    double const g = (1 - mu_y * ly) / (1 + mu_x * lx) * (1 - mu_x * lx) / (1 + mu_y * ly);
    double const amplitude = 0.5 * std::pow(g, static_cast<double>(steps));

    xt::xarray<double> expected = xt::empty<double>({H, W});
    for (size_t r = 0; r < H; ++r) {
      for (size_t col = 0; col < W; ++col) {
        expected(r, col) = 1.0 + amplitude * mode(kx, W, col) * mode(ky, H, r);
      }
    }

    INFO("species " << m << ", kx = " << kx << ", ky = " << ky << ", g = " << g);
    REQUIRE(maxAbsDiff(out.c[m], expected) < 1e-12);
  }
}

TEST_CASE("ADI solver: uniform fields follow the reaction terms alone", "[adi]") {
  // Diffusion leaves uniform fields untouched (including at the boundaries), so every cell must
  // follow the two explicit half step reaction updates
  double const dt = 1e-3;
  size_t const steps = 50;
  ym::ModelParameters const params({0.01, 0.02, 0.03, 0.04, 0.05}, {10.0, 5.0, 1.0});
  std::array<double, 5> c{5.0, 3.0, 0.2, 0.1, 0.05};

  ym::SolutionState ic(H, W);
  for (size_t m = 0; m < 5; ++m) {
    ic.c[m].fill(c[m]);
  }

  auto const out = solveFields(config(std::make_shared<ym::FixedTimeStep>(dt), steps), ic, params);

  xt::xarray<double> const R = 0.5 * dt * xt::linalg::dot(ym::Constants::S, xt::diag(params.k));
  auto const halfStep = [&](std::array<double, 5> const& s) {
    std::array<double, 5> next{};
    for (size_t m = 0; m < 5; ++m) {
      next[m] = s[m] + s[0] * (R(m, 0) * s[1] + R(m, 1) * s[2] + R(m, 2) * s[3]);
    }
    return next;
  };
  for (size_t i = 0; i < steps; ++i) {
    c = halfStep(halfStep(c));
  }

  for (size_t m = 0; m < 5; ++m) {
    INFO("species " << m);
    REQUIRE(maxAbsDiff(out.c[m], xt::xarray<double>(xt::full_like(out.c[m], c[m]))) < 1e-12);
  }
}

TEST_CASE("ADI solver: matches the previous LAPACK implementation", "[adi]") {
  std::mt19937 rng(42);
  ym::SolutionState const ic = randomState(rng);
  ym::ModelParameters const params({0.01, 0.02, 0.005, 0.001, 0.03}, {1.0, 0.5, 0.2});

  size_t const steps = 300;

  SECTION("fixed time step") {
    double const dt = 1e-3;
    auto const out =
        solveFields(config(std::make_shared<ym::FixedTimeStep>(dt), steps), ic, params);
    auto const expected = referenceSolve(ic, params, std::vector<double>(steps, dt));

    for (size_t m = 0; m < 5; ++m) {
      INFO("species " << m);
      REQUIRE(maxAbsDiff(out.c[m], expected.c[m]) < 1e-12);
    }
  }

  SECTION("geometric time step, the matrices are refactored every step") {
    double const dt_0 = 1e-4;
    double const r = 1.01;
    auto const out =
        solveFields(config(std::make_shared<ym::GeometricTimeStep>(dt_0, r), steps), ic, params);

    std::vector<double> dts(steps);
    double dt = dt_0;
    for (auto& d : dts) {
      d = dt;
      dt *= r;
    }
    auto const expected = referenceSolve(ic, params, dts);

    for (size_t m = 0; m < 5; ++m) {
      INFO("species " << m);
      REQUIRE(maxAbsDiff(out.c[m], expected.c[m]) < 1e-12);
    }
  }
}

TEST_CASE("ADI solver: total mass is conserved with reactions on", "[adi]") {
  // Every reaction in S is mass balanced, and diffusion with Neumann boundaries only moves mass
  std::mt19937 rng(5);
  ym::SolutionState const ic = randomState(rng);
  ym::ModelParameters const params({0.01, 0.02, 0.005, 0.001, 0.03}, {10.0, 5.0, 1.0});

  auto cfg = config(std::make_shared<ym::FixedTimeStep>(1e-3), 500);
  cfg.capture.reducer = std::make_shared<ym::TotalMassReducer>();
  cfg.capture.trigger = std::make_shared<ym::StrideTrigger>(1);

  auto const result = ym::solve(cfg, ic, params);
  auto const masses = result->all().values();
  REQUIRE(result->size() == 501);

  xt::xarray<double> const total = xt::sum(masses, {1});
  double const initial = total(0);

  // The reactions do happen, otherwise this test proves nothing: reagent mass is consumed and
  // the YAG mass grows
  REQUIRE(masses(500, 0) + masses(500, 1) < 0.9 * (masses(0, 0) + masses(0, 1)));
  REQUIRE(masses(500, 4) > 1.5 * masses(0, 4));

  for (size_t t = 0; t < result->size(); ++t) {
    REQUIRE(std::abs(total(t) - initial) < 1e-12 * initial);
  }
}
