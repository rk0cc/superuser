# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(superuser_plugin_windows_library VERSION 2.0.1 LANGUAGES C)

add_library(superuser_plugin_windows SHARED
  "superuser_plugin_windows.c"
)

set_target_properties(superuser_plugin_windows PROPERTIES
  PUBLIC_HEADER superuser_plugin_windows.h
  OUTPUT_NAME "superuser_plugin_windows"
)

target_compile_definitions(superuser_plugin_windows PUBLIC DART_SHARED_LIB)

target_link_libraries(superuser_plugin_windows netapi32)
