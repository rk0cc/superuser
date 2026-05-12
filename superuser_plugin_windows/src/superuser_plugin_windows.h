#ifndef FLUTTER_SUPERUSER_WINDOWS_H
#define FLUTTER_SUPERUSER_WINDOWS_H

#if !defined(__STDC_VERSION__) || __STDC_VERSION__ < 202311L
#include <stdbool.h> // C23 make "bool" type as built-in
#endif

#ifdef __cplusplus
extern "C"
{
#endif
#include <windows.h>

#define MAX_USERNAME_CHAR 257
#define WIN32API_FUNC_WLEN 129
#define NETBIOS_NAME_LEN 16
#define FFI_PLUGIN_EXPORT __declspec(dllexport)

    /*
        Returned value indicates the process result, which
        uses non-zero values to denotes problem during processing.
    */
    typedef DWORD ERRCODE;

    /*
        Well-structured information regarding returned error
        during function call.
    */
    typedef struct _SUPERUSER_ERRORINFO
    {
        ERRCODE code;
        WCHAR winapi_func_name[WIN32API_FUNC_WLEN];
    } SUPERUSER_ERRORINFO;

    /*
        A model contains group information, which is a member of an user
        who execute the program.
    */
    typedef struct _WINDOWS_GROUP_NAME
    {
        WCHAR name[MAX_USERNAME_CHAR];
        WCHAR domain[MAX_USERNAME_CHAR];
    } WINDOWS_GROUP_NAME;

    // Extract machine name in NetBIOS.
    FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO get_local_machine_name(LPWSTR *result);

    // Obtain name of user.
    FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO get_current_username(LPWSTR *result);

    // Get length of associated groups for current user.
    FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO count_associated_groups_length(PDWORD length);

    // Obtain user's associated group in local system.
    FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO get_associated_groups(WINDOWS_GROUP_NAME **groups);

    // Verify user who execute program has admin right.
    FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO is_admin_user(bool *result);

    // Determine this program is executed with admin.
    FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO is_elevated(bool *result);
#ifdef __cplusplus
}
#endif

#endif