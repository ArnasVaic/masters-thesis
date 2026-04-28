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
# Core library (ALL shared code goes here)
# --------------------------------------------------
add_library(core
        src/SolverState.cpp
        src/SolutionState.cpp
        src/Discretization.cpp
        src/ModelParameters.cpp
        src/Brakes/ReagentQuantityThresholdBrake.cpp
        src/Quantity.cpp
        src/Captures/FrameCapture.cpp
        src/CheckerboardInitialCondition.cpp
        src/TimeStep/FixedTimeStep.cpp
        src/TimeStep/FixedTimeStep.h
        src/ADISolver.tpp
        src/ADISolver.h
        src/ADISolverCache.cpp
        src/ADISolverCache.h
        src/TridiagonalLU.h
        src/TridiagonalLU.cpp
        src/MuCoefficients.h
        src/Captures/QuantityCapture.h
        src/Captures/QuantityCapture.cpp
        src/Brakes/FixedStepBrake.cpp
        src/Brakes/FixedStepBrake.h
)

target_include_directories(core PUBLIC src)

target_link_libraries(core PUBLIC
        xtensor
        ${LAPACK_LIBRARIES}
        ${BLAS_LIBRARIES}
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
file(GLOB_RECURSE TEST_SOURCES CONFIGURE_DEPENDS test/*.cpp)

add_executable(tests ${TEST_SOURCES}
        test/const_quant_test.cpp
)

target_link_libraries(tests PRIVATE
        core
        Catch2::Catch2WithMain
)

include(Catch)
catch_discover_tests(tests)