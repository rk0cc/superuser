#ifndef FLUTTER_SUPERUSER_WINDOWS_H
#define FLUTTER_SUPERUSER_WINDOWS_H

#include <stdbool.h>
#include <windows.h>

#define FFI_PLUGIN_EXPORT __declspec(dllexport)

// Verify user who execute program has admin right.
FFI_PLUGIN_EXPORT bool is_admin_user();

// Determine this program is executed with admin.
FFI_PLUGIN_EXPORT bool is_elevated();

// Obtain name of user.
FFI_PLUGIN_EXPORT DWORD get_current_username(char** result);

/// Flush string from dynamic allocated function.
FFI_PLUGIN_EXPORT void flush_string(char* str);

#endif
