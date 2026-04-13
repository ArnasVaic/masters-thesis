cmake_minimum_required(VERSION 3.20)
project(test_xtensor LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)

find_package(xtensor REQUIRED)

add_executable(app src/main.cpp)

target_link_libraries(app PRIVATE xtensor)