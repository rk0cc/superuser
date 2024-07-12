#ifndef FLUTTER_SUPERUSER_WINDOWS_H
#define FLUTTER_SUPERUSER_WINDOWS_H

#include <windows.h>

#define FFI_PLUGIN_EXPORT __declspec(dllexport)

// Verify user who execute program has admin right.
FFI_PLUGIN_EXPORT BOOL is_admin_user();

// Determine this program is executed with admin.
FFI_PLUGIN_EXPORT BOOL is_elevated();

// Obtain name of user.
FFI_PLUGIN_EXPORT LPWSTR get_current_username();

#endif
