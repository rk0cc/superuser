# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(superuser_plugin_unix_library VERSION 2.0.0 LANGUAGES C)

add_library(superuser_plugin_unix SHARED
  "superuser_plugin_unix.c"
)

set_target_properties(superuser_plugin_unix PROPERTIES
  PUBLIC_HEADER superuser_plugin_unix.h
  OUTPUT_NAME "superuser_plugin_unix"
)

target_compile_definitions(superuser_plugin_unix PUBLIC DART_SHARED_LIB)
