cmake_minimum_required(VERSION 3.27.1)

project(
    nil-cmake
    VERSION 0.0.1
    DESCRIPTION "collection of utility functionalities"
)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

include(cmake/package.cmake)

install_config("config.cmake.in")

install(
    FILES
        cmake/package.cmake
        cmake/toolchain.cmake
        cmake/quality.cmake
        cmake/test.cmake
        cmake/cpack.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${CMAKE_PROJECT_NAME}
)