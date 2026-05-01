cmake_minimum_required(VERSION 3.20)
project(yag_model LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(CTest)
enable_testing()

find_package(xtensor CONFIG REQUIRED)
find_package(Catch2 3 CONFIG REQUIRED)
find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)

# --------------------------------------------------
# Core: low-level utilities
# --------------------------------------------------
add_library(core_base
        src/Core/Quantity.cpp
        src/Core/SolutionState.cpp
        src/Core/TridiagonalLU.cpp
)

target_include_directories(core_base PUBLIC src)

target_link_libraries(core_base PUBLIC
        xtensor
)

# --------------------------------------------------
# Model / configuration layer
# --------------------------------------------------
add_library(core_model
        src/Core/SolverState.cpp
        src/Config/ModelParameters.cpp
        src/Config/Discretization.cpp
        src/InitialCondition/CheckerboardInitialCondition.cpp
)

target_include_directories(core_model PUBLIC src)

target_link_libraries(core_model PUBLIC core_base)

# --------------------------------------------------
# Time stepping / solver layer
# --------------------------------------------------
add_library(core_solver
        src/TimeStep/FixedTimeStep.cpp
        src/Solver/ADISolverCache.cpp
        src/Solver/ADISolver.tpp
        src/TimeStep/ITimeStep.h
)

target_include_directories(core_solver PUBLIC src)

target_link_libraries(core_solver PUBLIC
        core_model
        ${LAPACK_LIBRARIES}
        ${BLAS_LIBRARIES}
)

# --------------------------------------------------
# Capture / IO
# --------------------------------------------------
add_library(core_capture
        src/CaptureTrigger/FrameCapture.cpp
        src/CaptureTrigger/QuantityCapture.cpp
        src/CaptureTrigger/ICaptureTrigger.h
        src/CaptureTrigger/StrideCaptureTrigger.cpp
        src/CaptureTrigger/StrideCaptureTrigger.h
)

target_include_directories(core_capture PUBLIC src)

target_link_libraries(core_capture PUBLIC core_base)

# --------------------------------------------------
# Brakes / logic
# --------------------------------------------------
add_library(core_brakes
        src/Brakes/ReagentQuantityThresholdBrake.cpp
        src/Brakes/FixedStepBrake.cpp
        src/Brakes/IBrake.h
)

target_include_directories(core_brakes PUBLIC src)

target_link_libraries(core_brakes PUBLIC core_base)

# --------------------------------------------------
# High-level core facade
# --------------------------------------------------
add_library(core INTERFACE)

target_link_libraries(core INTERFACE
        core_base
        core_model
        core_solver
        core_capture
        core_brakes
)

# --------------------------------------------------
# Main app
# --------------------------------------------------
add_executable(app
        src/main.cpp
)

target_link_libraries(app PRIVATE core)

# --------------------------------------------------
# Tests
# --------------------------------------------------
add_executable(tests
        test/lapack_test.cpp
        test/checkerboard_ic_test.cpp
        test/unsymmetric_resolution_const_quant_test.cpp
        test/const_quant_test.cpp
        test/xtensor_test.cpp
)

target_link_libraries(tests PRIVATE
        core
        Catch2::Catch2WithMain
)

include(Catch)
# catch_discover_tests(tests)