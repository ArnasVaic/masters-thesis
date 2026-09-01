cmake_minimum_required(VERSION 3.20)
project(yag_model LANGUAGES CXX)

if (DEFINED ENV{CONDA_PREFIX})
    list(PREPEND CMAKE_PREFIX_PATH "$ENV{CONDA_PREFIX}")
endif ()

set(CMAKE_CXX_FLAGS_RELWITHDEBINFO
        "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -O2 -g -fno-omit-frame-pointer")

if (NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
            Debug Release RelWithDebInfo MinSizeRel)
endif ()

set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(BUILD_PYTHON "Build Python module" ON)
option(BUILD_APP "Build app" ON)
option(BUILD_TESTS "Build tests" ON)

include(CTest)
enable_testing()


find_package(Catch2 3 CONFIG REQUIRED)
find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)

find_package(Python3 REQUIRED COMPONENTS Interpreter Development NumPy)
find_package(pybind11 CONFIG REQUIRED)
find_package(xtensor CONFIG REQUIRED)
find_package(xtensor-python REQUIRED)
find_package(xtensor-blas CONFIG REQUIRED)

# --------------------------------------------------
# Core: low-level utilities
# --------------------------------------------------
add_library(core_base
        src/Core/Quantity.cpp
        src/Core/SolutionState.cpp
        src/Core/TridiagonalLU.cpp
        src/Core/Constants.h
)

target_include_directories(core_base PUBLIC src)

target_link_libraries(core_base PUBLIC
        xtensor
        xtensor-blas
        ${LAPACK_LIBRARIES}
        ${BLAS_LIBRARIES}
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
        src/Solver/ADISolver.cpp
        src/TimeStep/ITimeStep.h
)

target_include_directories(core_solver PUBLIC src)

target_link_libraries(core_solver PUBLIC
        core_model
)

# --------------------------------------------------
# Capture / IO
# --------------------------------------------------
add_library(core_capture
        src/Captures/InMemoryFrameCapture.cpp
        src/Captures/QuantityCapture.cpp
        src/CaptureTrigger/ICaptureTrigger.h
        src/CaptureTrigger/StrideCaptureTrigger.cpp
        src/CaptureTrigger/StrideCaptureTrigger.h
        src/Captures/ICapture.h
        src/CaptureTrigger/LastFrameCaptureTrigger.cpp
        src/CaptureTrigger/LastFrameCaptureTrigger.h
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
        src/Brakes/TimeBrake.cpp
        src/Brakes/TimeBrake.h
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

#
# Bindings
#
if (BUILD_PYTHON)
    pybind11_add_module(yag_model
            src/bindings.cpp
    )
    target_link_libraries(yag_model PUBLIC pybind11::module Python3::Python Python3::NumPy xtensor-python xtensor-blas)
    target_link_libraries(yag_model PRIVATE core)

    install(TARGETS yag_model LIBRARY DESTINATION .)
endif ()

# --------------------------------------------------
# Main app
# --------------------------------------------------
#if (BUILD_APP)
add_executable(app src/main.cpp)
target_link_libraries(app PRIVATE core)
#endif ()

# --------------------------------------------------
# Tests
# --------------------------------------------------
if (BUILD_TESTS)
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
endif ()
