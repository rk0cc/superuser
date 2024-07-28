#include <Windows.h>
#include <LM.h>
#include <stdlib.h>

#include "superuser_plugin_windows.h"

#define MAX_USERNAME_CHAR 256

BOOL __wchar_to_utf8(WCHAR* wc, char** utf)
{
    int buf8_size = WideCharToMultiByte(CP_UTF8, 0, wc, -1, NULL, 0, NULL, NULL);

    *utf = (char *) calloc(buf8_size, sizeof(char));

    return WideCharToMultiByte(CP_UTF8, 0, wc, -1, *utf, buf8_size, NULL, NULL);
}

ERRCODE __obtain_user_local_group(LPBYTE* gp, DWORD* entries, DWORD* total)
{
    WCHAR ubuf[MAX_USERNAME_CHAR];
    DWORD ubufLen = sizeof(ubuf) / sizeof(ubuf[0]);

    SetLastError(0);

    if (!GetUserNameW(ubuf, &ubufLen))
        return GetLastError();

    NET_API_STATUS status;
    status = NetUserGetLocalGroups(NULL, ubuf, 0, LG_INCLUDE_INDIRECT, gp, MAX_PREFERRED_LENGTH, entries, total);
    if (status)
        return status;

    return 0;
}

// Verify user who execute program has admin right.
FFI_PLUGIN_EXPORT ERRCODE is_admin_user(bool* result)
{
    result = NULL;

    LPBYTE buf;
    DWORD entries, total;

    ERRCODE err = __obtain_user_local_group(&buf, &entries, &total);
    if (err)
        return err;

    LPCWSTR adminGpName = L"Administrators";
    LOCALGROUP_USERS_INFO_0* lg = (LOCALGROUP_USERS_INFO_0*) buf;
    
    bool tmp_result = false;
    for (DWORD i = 0; i < entries; i++)
    {
        if (wcscmp(adminGpName, lg[i].lgrui0_name) == 0)
        {
            tmp_result = true;
            break;
        }
    }

    result = &tmp_result;

    NetApiBufferFree(buf);

    return 0;
}

// Determine this program is executed with admin.
FFI_PLUGIN_EXPORT ERRCODE is_elevated(bool* result)
{
    result = NULL;
    HANDLE token = NULL;

    SetLastError(0);
    if (!OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &token))
        return GetLastError();
    
    TOKEN_ELEVATION elevation;
    DWORD cbSize = sizeof(TOKEN_ELEVATION);

    SetLastError(0);
    if (!GetTokenInformation(token, TokenElevation, &elevation, sizeof elevation, &cbSize))
        return GetLastError();

    bool tmp_result = elevation.TokenIsElevated ? true : false;

    result = &tmp_result;

    if (token)
        CloseHandle(token);

    return 0;
}

// Obtain name of user.
FFI_PLUGIN_EXPORT ERRCODE get_current_username(char** result)
{
    result = NULL;

    WCHAR buffer[MAX_USERNAME_CHAR];
    DWORD bufLen = sizeof(buffer) / sizeof(buffer[0]);

    SetLastError(0);
    if (!GetUserNameW(buffer, &bufLen))
        return GetLastError();

    SetLastError(0);
    if (!__wchar_to_utf8(buffer, result))
        return GetLastError();

    return 0;
}

// Obtain user's associated group in local system.
FFI_PLUGIN_EXPORT ERRCODE get_associated_groups(char*** groups, DWORD* length)
{
    groups = NULL;
    length = NULL;

    LPBYTE buf;
    DWORD entries, total;

    ERRCODE err = __obtain_user_local_group(&buf, &entries, &total);
    if (err)
        return err;

    char** tmp_groups = (char**) calloc(entries, sizeof(char*));

    LOCALGROUP_USERS_INFO_0* lg = (LOCALGROUP_USERS_INFO_0*) buf;
    for (DWORD i = 0; i < entries; i++)
    {
        if (!__wchar_to_utf8(lg[i].lgrui0_name, &tmp_groups[i]))
            return GetLastError();
    }

    NetApiBufferFree(buf);

    length = &entries;
    groups = &tmp_groups;

    return 0;
}

// Flush dynamic allocated function.
FFI_PLUGIN_EXPORT void flush(void* ptr)
{
    free(ptr);
}
