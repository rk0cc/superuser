#include <Windows.h>
#include <LM.h>
#include <stdlib.h>

#include "superuser_plugin_windows.h"

#define MAX_USERNAME_CHAR 256

BOOL __wchar_to_utf8(WCHAR *wc, char **utf)
{
    int buf8_size = WideCharToMultiByte(CP_UTF8, 0, wc, -1, NULL, 0, NULL, NULL);

    *utf = (char *)calloc(buf8_size, sizeof(char));

    return WideCharToMultiByte(CP_UTF8, 0, wc, -1, *utf, buf8_size, NULL, NULL);
}

ERRCODE __obtain_user_local_group(LPBYTE *gp, DWORD *entries, DWORD *total)
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

int __sort_search_lguser(void *context, const void *a, const void *b)
{
    LPCWCHAR aChar, bChar;

    aChar = (*(LOCALGROUP_USERS_INFO_0 *)a).lgrui0_name;
    bChar = (*(LOCALGROUP_USERS_INFO_0 *)b).lgrui0_name;

    return wcscmp(aChar, bChar);
}

// Verify user who execute program has admin right.
FFI_PLUGIN_EXPORT ERRCODE is_admin_user(bool *result)
{
    LPBYTE buf;
    DWORD entries, total;

    ERRCODE err = __obtain_user_local_group(&buf, &entries, &total);
    if (err)
    {
        if (buf)
            NetApiBufferFree(buf);

        return err;
    }

    LOCALGROUP_USERS_INFO_0 key = {.lgrui0_name = L"Administrators"};
    LOCALGROUP_USERS_INFO_0 *lg = (LOCALGROUP_USERS_INFO_0 *)buf;

    errno = 0;
    qsort_s(lg, entries, sizeof(LOCALGROUP_USERS_INFO_0), __sort_search_lguser, NULL);
    if (errno == EINVAL)
    {
        NetApiBufferFree(buf);

        return ERROR_INVALID_PARAMETER;
    }

    errno = 0;
    LOCALGROUP_USERS_INFO_0 *found = (LOCALGROUP_USERS_INFO_0 *)bsearch_s(&key, lg, entries, sizeof(LOCALGROUP_USERS_INFO_0), __sort_search_lguser, NULL);
    if (errno == EINVAL)
    {
        NetApiBufferFree(buf);

        return ERROR_INVALID_PARAMETER;
    }

    bool tmp_result = found != NULL;
    *result = tmp_result;

    NetApiBufferFree(buf);

    return 0;
}

// Determine this program is executed with admin.
FFI_PLUGIN_EXPORT ERRCODE is_elevated(bool *result)
{
    HANDLE token;

    SetLastError(0);
    if (!OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &token))
    {
        if (token)
            CloseHandle(token);
        
        return GetLastError();
    }

    TOKEN_ELEVATION elevation;
    DWORD cbSize = sizeof(TOKEN_ELEVATION);

    SetLastError(0);
    if (!GetTokenInformation(token, TokenElevation, &elevation, sizeof elevation, &cbSize))
    {
        CloseHandle(token);

        return GetLastError();
    }

    bool tmp_result = elevation.TokenIsElevated ? true : false;

    *result = tmp_result;

    CloseHandle(token);

    return 0;
}

// Obtain name of user.
FFI_PLUGIN_EXPORT ERRCODE get_current_username(char **result)
{
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
FFI_PLUGIN_EXPORT ERRCODE get_associated_groups(char ***groups, DWORD *length)
{
    LPBYTE buf;
    DWORD entries, total;

    ERRCODE err = __obtain_user_local_group(&buf, &entries, &total);
    if (err)
    {
        if (buf)
            NetApiBufferFree(buf);

        return err;
    }

    char **tmp_groups = (char **)calloc(entries, sizeof(char *));

    LOCALGROUP_USERS_INFO_0 *lg = (LOCALGROUP_USERS_INFO_0 *)buf;
    for (DWORD i = 0; i < entries; i++)
    {
        if (!__wchar_to_utf8(lg[i].lgrui0_name, &tmp_groups[i]))
        {
            NetApiBufferFree(buf);

            return GetLastError();
        }
    }

    NetApiBufferFree(buf);

    *length = entries;
    *groups = tmp_groups;

    return 0;
}

// Flush dynamic allocated function.
FFI_PLUGIN_EXPORT void flush(void *ptr)
{
    free(ptr);
}
