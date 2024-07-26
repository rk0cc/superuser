#include <Windows.h>
#include <LM.h>
#include <stdlib.h>

#include "superuser_plugin_windows.h"

#define MAX_USERNAME_CHAR 256

typedef const void* BSEARCH_CMPPTR;

int __local_group_cmp(BSEARCH_CMPPTR a, BSEARCH_CMPPTR b)
{
    LPWSTR aGpName = ((LOCALGROUP_USERS_INFO_0 *)a)->lgrui0_name;
    LPWSTR bGpName = ((LOCALGROUP_USERS_INFO_0 *)b)->lgrui0_name;

    return wcscmp(aGpName, bGpName);
}

// Verify user who execute program has admin right.
FFI_PLUGIN_EXPORT ERRCODE is_admin_user(bool* result)
{
    *result = false;
    
    WCHAR ubuf[MAX_USERNAME_CHAR];
    DWORD ubufLen = sizeof(ubuf) / sizeof(ubuf[0]);

    SetLastError(0);

    if (!GetUserNameW(ubuf, &ubufLen))
        return GetLastError();

    LPBYTE buf;
    DWORD entries, total;

    NET_API_STATUS status;
    status = NetUserGetLocalGroups(NULL, ubuf, 0, LG_INCLUDE_INDIRECT, &buf, MAX_PREFERRED_LENGTH, &entries, &total);
    if (status)
        return status;

    const LOCALGROUP_USERS_INFO_0 adminCond = {
        .lgrui0_name = L"Administrators"
    };
    LOCALGROUP_USERS_INFO_0* lg = (LOCALGROUP_USERS_INFO_0*) buf;
    
    LOCALGROUP_USERS_INFO_0* bsRes = (LOCALGROUP_USERS_INFO_0*) bsearch_s(&adminCond, lg, entries, sizeof(LOCALGROUP_USERS_INFO_0), __local_group_cmp, NULL);

    if (bsRes)
        *result = true;

    NetApiBufferFree(buf);

    return 0;
}

// Determine this program is executed with admin.
FFI_PLUGIN_EXPORT ERRCODE is_elevated(bool* result)
{
    *result = false;
    HANDLE token = NULL;

    SetLastError(0);
    if (!OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &token))
        return GetLastError();
    
    TOKEN_ELEVATION elevation;
    DWORD cbSize = sizeof(TOKEN_ELEVATION);

    SetLastError(0);
    if (!GetTokenInformation(token, TokenElevation, &elevation, sizeof elevation, &cbSize))
        return GetLastError();

    *result = elevation.TokenIsElevated;

    if (token)
        CloseHandle(token);

    return 0;
}

// Obtain name of user.
FFI_PLUGIN_EXPORT ERRCODE get_current_username(char** result)
{
    WCHAR buffer[MAX_USERNAME_CHAR];
    DWORD bufLen = sizeof(buffer) / sizeof(buffer[0]);

    SetLastError(0);

    if (!GetUserNameW(buffer, &bufLen))
        return GetLastError();

    int buf8_size = WideCharToMultiByte(CP_UTF8, 0, buffer, -1, NULL, 0, NULL, NULL);

    *result = (char *) calloc(buf8_size, sizeof(char));

    if (!WideCharToMultiByte(CP_UTF8, 0, buffer, -1, *result, buf8_size, NULL, NULL))
        return GetLastError();

    return 0;
}

/// Flush string from dynamic allocated function.
FFI_PLUGIN_EXPORT void flush_string(char* str)
{
    free(str);
}
