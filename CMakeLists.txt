cmake_minimum_required(VERSION 3.17)

project(kat_helper)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "-Wall -Wpedantic")

add_subdirectory(parser)

add_executable(main
  main.cpp
)

target_link_libraries(main
  rsp_parser
)

install(TARGETS main DESTINATION ${CMAKE_BINARY_DIR}/bin)
