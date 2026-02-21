cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "glow")
project(${PROJECT_NAME} LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(PLUGIN_NAME "glow_plugin")

# -----------------------------------------------------------------------
# Build the Rust shared library via cargo
# -----------------------------------------------------------------------
set(RUST_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../rust")
set(RUST_LIB_NAME "flutter_opengl_rust")

# Determine Rust build profile and output directory
if(CMAKE_BUILD_TYPE STREQUAL "Release")
  set(RUST_PROFILE "release")
  set(CARGO_BUILD_FLAGS --release)
else()
  set(RUST_PROFILE "debug")
  set(CARGO_BUILD_FLAGS "")
endif()

set(RUST_TARGET_DIR "${CMAKE_CURRENT_BINARY_DIR}/rust-target")
set(RUST_LIB_DIR "${RUST_TARGET_DIR}/${RUST_PROFILE}")
set(RUST_LIB_PATH "${RUST_LIB_DIR}/lib${RUST_LIB_NAME}.so")

add_custom_target(glow_rust_lib ALL
  BYPRODUCTS "${RUST_LIB_PATH}"
  COMMAND cargo build --locked --target-dir "${RUST_TARGET_DIR}" ${CARGO_BUILD_FLAGS}
  WORKING_DIRECTORY ${RUST_DIR}
  COMMENT "Building Rust library (${RUST_PROFILE})"
)

# Import the Rust shared library as a CMake target
add_library(${RUST_LIB_NAME} SHARED IMPORTED)
set_target_properties(${RUST_LIB_NAME} PROPERTIES
  IMPORTED_LOCATION ${RUST_LIB_PATH}
  IMPORTED_NO_SONAME TRUE
)
add_dependencies(${RUST_LIB_NAME} glow_rust_lib)

# -----------------------------------------------------------------------
# Plugin sources (no more C++ engine sources)
# -----------------------------------------------------------------------
set(PLUGIN_SOURCES
  flutter_opengl_plugin.cc
  fl_my_texture_gl.cc
)

add_library(${PLUGIN_NAME} SHARED ${PLUGIN_SOURCES})

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden
  INSTALL_RPATH "$ORIGIN"
  BUILD_WITH_INSTALL_RPATH TRUE)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_compile_options(${PLUGIN_NAME} PRIVATE -Wall -Wno-error)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
target_include_directories(${PLUGIN_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_SOURCE_DIR}"
)

target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

# OpenGL + EGL + GLEW (still needed for glGenTextures in the plugin)
find_package(OpenGL REQUIRED COMPONENTS OpenGL EGL)
target_link_libraries(${PLUGIN_NAME} PRIVATE
  OpenGL::OpenGL
  OpenGL::EGL
  GLEW
)

# Link against the Rust shared library
target_link_libraries(${PLUGIN_NAME} PRIVATE ${RUST_LIB_NAME})

# Bundle the Rust .so with the Flutter application
set(glow_bundled_libraries
  "${RUST_LIB_PATH}"
  PARENT_SCOPE
)
