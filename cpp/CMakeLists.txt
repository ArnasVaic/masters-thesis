cmake_minimum_required(VERSION 3.20)
project(yag_model LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)

include(CTest) # enables testing
enable_testing()

find_package(xtensor CONFIG REQUIRED)
find_package(Catch2 3 CONFIG REQUIRED)
find_package(LAPACK REQUIRED)

# main app
add_executable(app src/main.cpp
        src/SolverState.cpp
        src/SolverState.h
        src/SolutionState.cpp
        src/SolutionState.h
        src/Discretization.cpp
        src/Discretization.h
        src/ReactionParameters.cpp
        src/ReactionParameters.h
        src/ReagentQuantityThresholdBrake.cpp
        src/ReagentQuantityThresholdBrake.h
        src/Quantity.h
        src/Quantity.cpp
        src/StridedCapture.cpp
        src/StridedCapture.h
)
target_link_libraries(app PRIVATE xtensor LAPACK::LAPACK)
# test executable
file(GLOB_RECURSE TEST_SOURCES CONFIGURE_DEPENDS test/*.cpp)
add_executable(tests ${TEST_SOURCES})
target_link_libraries(tests PRIVATE xtensor LAPACK::LAPACK Catch2::Catch2WithMain)

# register tests
include(Catch)
catch_discover_tests(tests)