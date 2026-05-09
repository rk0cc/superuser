#include <Windows.h>
#include <LM.h>
#include <stdlib.h>

#include "superuser_plugin_windows.h"

#define WIN_ADMIN_PARAM L"Administrators"

void __get_current_username(SUPERUSER_ERRORINFO *errinfo, LPWSTR *uname)
{
    WCHAR ubuf[MAX_USERNAME_CHAR];
    DWORD ubufLen = sizeof(ubuf) / sizeof(ubuf[0]);

    SetLastError(0);
    BOOL success = GetUserNameW(ubuf, &ubufLen);
    if (!success)
    {
        errinfo->code = GetLastError();
        wcscpy_s(errinfo->winapi_func_name, WIN32API_FUNC_WLEN, L"GetUserNameW");

        return;
    }

    errno_t cpy_errno = wcscpy_s(*uname, MAX_USERNAME_CHAR, ubuf);
    if (cpy_errno != ERROR_SUCCESS)
    {
        errinfo->code = cpy_errno;
        wcscpy_s(errinfo->winapi_func_name, WIN32API_FUNC_WLEN, L"wcscpy_s");
    }
}

void __obtain_user_local_group(SUPERUSER_ERRORINFO *errinfo, LPBYTE *gp, PDWORD entries, PDWORD total)
{
    WCHAR ubuf[MAX_USERNAME_CHAR];
    __get_current_username(errinfo, &ubuf);
    
    if (errinfo->code != 0)
        return;


    NET_API_STATUS status = NetUserGetLocalGroups(NULL,
                                                  ubuf,
                                                  0,
                                                  LG_INCLUDE_INDIRECT,
                                                  gp,
                                                  MAX_PREFERRED_LENGTH,
                                                  entries,
                                                  total);
    if (status != NERR_Success)
    {
        errinfo->code = status;
        wcscpy_s(errinfo->winapi_func_name, WIN32API_FUNC_WLEN, L"NetUserGetLocalGroups");
    }
}

int __sort_search_lguser(const void *a, const void *b)
{
    LPCWCHAR aChar, bChar;

    aChar = (*(LOCALGROUP_USERS_INFO_0 *)a).lgrui0_name;
    bChar = (*(LOCALGROUP_USERS_INFO_0 *)b).lgrui0_name;

    return wcscmp(aChar, bChar);
}

// Verify user who execute program has admin right.
FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO is_admin_user(bool *result)
{
    SUPERUSER_ERRORINFO errinfo = {0};

    LPBYTE buf;
    DWORD entries, total;

    __obtain_user_local_group(&errinfo, &buf, &entries, &total);
    if (errinfo.code != ERROR_SUCCESS)
    {
        if (buf)
            NetApiBufferFree(buf);

        return errinfo;
    }

    LOCALGROUP_USERS_INFO_0 key = {.lgrui0_name = WIN_ADMIN_PARAM};
    LOCALGROUP_USERS_INFO_0 *lg = (LOCALGROUP_USERS_INFO_0 *)buf;

    qsort(lg, entries, sizeof(LOCALGROUP_USERS_INFO_0), __sort_search_lguser);
    LOCALGROUP_USERS_INFO_0 *found = (LOCALGROUP_USERS_INFO_0 *)bsearch(&key,
                                                                        lg,
                                                                        entries,
                                                                        sizeof(LOCALGROUP_USERS_INFO_0),
                                                                        __sort_search_lguser);

    bool tmp_result = found != NULL;
    *result = tmp_result;

    NetApiBufferFree(buf);

    return errinfo;
}

// Determine this program is executed with admin.
FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO is_elevated(bool *result)
{
    SUPERUSER_ERRORINFO errinfo = {0};
    HANDLE token;

    SetLastError(0);
    BOOL tokenOpened = OpenProcessToken(GetCurrentProcess(),
                                        TOKEN_QUERY,
                                        &token);
    if (!tokenOpened)
    {
        if (token)
            CloseHandle(token);

        errinfo.code = GetLastError();
        wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"OpenProcessToken");

        return errinfo;
    }

    TOKEN_ELEVATION elevation;
    DWORD cbSize = sizeof(TOKEN_ELEVATION);

    SetLastError(0);
    BOOL hasInfo = GetTokenInformation(token,
                                       TokenElevation,
                                       &elevation,
                                       sizeof(elevation),
                                       &cbSize);
    if (!hasInfo)
    {
        CloseHandle(token);

        errinfo.code = GetLastError();
        wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"GetTokenInformation");

        return errinfo;
    }

    bool tmp_result = elevation.TokenIsElevated ? true : false;
    *result = tmp_result;

    CloseHandle(token);

    return errinfo;
}

// Obtain name of user.
FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO get_current_username(LPWSTR *result)
{
    SUPERUSER_ERRORINFO errinfo = {0};

    __get_current_username(&errinfo, result);

    return errinfo;
}

// Get length of associated groups for current user.
FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO count_associated_groups_length(PDWORD length)
{
    SUPERUSER_ERRORINFO errinfo = {0};

    LPBYTE buf = NULL;
    DWORD entries, total;

    __obtain_user_local_group(&errinfo, &buf, &entries, &total);
    if (errinfo.code)
    {
        if (buf)
            NetApiBufferFree(buf);

        return errinfo;
    }

    *length = entries;

    return errinfo;
}

// Obtain user's associated group in local system.
FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO get_associated_groups(LPWSTR **groups)
{
    SUPERUSER_ERRORINFO errinfo = {0};

    LPBYTE buf = NULL;
    DWORD entries, total;

    __obtain_user_local_group(&errinfo, &buf, &entries, &total);
    if (errinfo.code)
    {
        if (buf)
            NetApiBufferFree(buf);

        return errinfo;
    }

    LOCALGROUP_USERS_INFO_0 *lg = (LOCALGROUP_USERS_INFO_0 *)buf;
    for (DWORD i = 0; i < entries; i++)
    {
        errno_t cp_err = wcscpy_s((*groups)[i], MAX_USERNAME_CHAR, lg[i].lgrui0_name);
        if (cp_err)
        {
            NetApiBufferFree(buf);

            errinfo.code = cp_err;
            wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"wcscpy_s");

            return errinfo;
        }
    }

    NetApiBufferFree(buf);

    return errinfo;
}
