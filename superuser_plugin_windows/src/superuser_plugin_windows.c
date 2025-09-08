#include <Windows.h>
#include <LM.h>
#include <stdlib.h>

#include "superuser_plugin_windows.h"

#define WIN_ADMIN_PARAM L"Administrators"

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

    return ERROR_SUCCESS;
}

int __sort_search_lguser(const void *a, const void *b)
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

    LOCALGROUP_USERS_INFO_0 key = {.lgrui0_name = WIN_ADMIN_PARAM};
    LOCALGROUP_USERS_INFO_0 *lg = (LOCALGROUP_USERS_INFO_0 *)buf;

    qsort(lg, entries, sizeof(LOCALGROUP_USERS_INFO_0), __sort_search_lguser);
    LOCALGROUP_USERS_INFO_0 *found = (LOCALGROUP_USERS_INFO_0 *)bsearch(&key, lg, entries, sizeof(LOCALGROUP_USERS_INFO_0), __sort_search_lguser);

    bool tmp_result = found != NULL;
    *result = tmp_result;

    NetApiBufferFree(buf);

    return ERROR_SUCCESS;
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
FFI_PLUGIN_EXPORT ERRCODE get_current_username(LPWSTR *result)
{
    WCHAR ubuf[MAX_USERNAME_CHAR];
    DWORD ubufLen = sizeof(ubuf) / sizeof(ubuf[0]);

    SetLastError(0);
    if (!GetUserNameW(ubuf, &ubufLen))
        return GetLastError();

    errno_t cpy_errno = wcscpy_s(*result, MAX_USERNAME_CHAR, ubuf);

    return cpy_errno ? ERROR_INVALID_PARAMETER : 0;
}

// Get length of associated groups for current user.
FFI_PLUGIN_EXPORT ERRCODE count_associated_groups_length(PDWORD length)
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

    *length = entries;

    return ERROR_SUCCESS;
}

// Obtain user's associated group in local system.
FFI_PLUGIN_EXPORT ERRCODE get_associated_groups(LPWSTR **groups)
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

    LOCALGROUP_USERS_INFO_0 *lg = (LOCALGROUP_USERS_INFO_0 *)buf;
    for (DWORD i = 0; i < entries; i++)
    {
        if (wcscpy_s((*groups)[i], MAX_USERNAME_CHAR, lg[i].lgrui0_name))
        {
            NetApiBufferFree(buf);

            return ERROR_INVALID_PARAMETER;
        }
    }

    NetApiBufferFree(buf);

    return 0;
}
