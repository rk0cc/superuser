#ifndef FLUTTER_SUPERUSER_WINDOWS_H
#define FLUTTER_SUPERUSER_WINDOWS_H

#ifdef __cplusplus
extern "C"
{
#endif
#include <stdbool.h>
#include <windows.h>

#define FFI_PLUGIN_EXPORT __declspec(dllexport)

    // Returned value indicates the process result, which
    // uses non-zero values to denotes problem during processing.
    typedef DWORD ERRCODE;

    // Verify user who execute program has admin right.
    FFI_PLUGIN_EXPORT ERRCODE is_admin_user(bool *result);

    // Determine this program is executed with admin.
    FFI_PLUGIN_EXPORT ERRCODE is_elevated(bool *result);

    // Obtain name of user.
    FFI_PLUGIN_EXPORT ERRCODE get_current_username(char **result);

    // Obtain user's associated group in local system.
    FFI_PLUGIN_EXPORT ERRCODE get_associated_groups(char ***groups, DWORD *length);

    // Free allocated memory of string.
    FFI_PLUGIN_EXPORT void flush_cstr(char *str);

    // Wipe all data in 2D allocated memory of string.
    FFI_PLUGIN_EXPORT void flush_cstr_array(char **str_array, DWORD length);

#ifdef __cplusplus
}
#endif

#endif