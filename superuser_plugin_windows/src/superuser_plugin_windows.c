#include <stdlib.h>

#include "superuser_plugin_windows.h"

#define WIN_ADMIN_PARAM L"Administrators"
#define WINAPICALL_STATUS \
    SetLastError(0);      \
    BOOL

void __get_current_username(SUPERUSER_ERRORINFO *errinfo, LPWSTR *uname)
{
    WCHAR ubuf[MAX_USERNAME_CHAR];
    DWORD ubufLen = sizeof(ubuf) / sizeof(ubuf[0]);

    WINAPICALL_STATUS success = GetUserNameW(ubuf, &ubufLen);
    if (!success)
    {
        errinfo->code = GetLastError();
        wcscpy_s(errinfo->winapi_func_name, WIN32API_FUNC_WLEN, L"GetUserNameW (__get_current_username)");

        return;
    }

    errno_t cpy_errno = wcscpy_s(*uname, MAX_USERNAME_CHAR, ubuf);
    if (cpy_errno != ERROR_SUCCESS)
    {
        errinfo->code = cpy_errno;
        wcscpy_s(errinfo->winapi_func_name, WIN32API_FUNC_WLEN, L"wcscpy_s (__get_current_username)");
    }
}

void __open_handle_token(SUPERUSER_ERRORINFO *errinfo, HANDLE *hToken)
{
    WINAPICALL_STATUS opened = OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, hToken);

    if (!opened)
    {
        errinfo->code = GetLastError();
        wcscpy_s(errinfo->winapi_func_name, WIN32API_FUNC_WLEN, L"OpenProcessToken (__open_handle_token)");
    }
}

void __get_group_token(SUPERUSER_ERRORINFO *errinfo, HANDLE *hToken, PTOKEN_GROUPS *gpInfo)
{
    DWORD gpSize;
    WINAPICALL_STATUS hasBuf = GetTokenInformation(hToken,
                                                   TokenGroups,
                                                   NULL,
                                                   0,
                                                   &gpSize);
    ERRCODE bufErrCode = GetLastError();
    if (bufErrCode != ERROR_INSUFFICIENT_BUFFER)
    {
        errinfo->code = bufErrCode;
        wcscpy_s(errinfo->winapi_func_name, WIN32API_FUNC_WLEN, L"GetTokenInformation (__get_group_token, buffer)");

        return;
    }

    SetLastError(0);
    PTOKEN_GROUPS tmpGpInfo = (PTOKEN_GROUPS)LocalAlloc(LPTR, gpSize);
    if (!tmpGpInfo)
    {
        errinfo->code = GetLastError();
        wcscpy_s(errinfo->winapi_func_name, WIN32API_FUNC_WLEN, L"LocalAlloc (__get_group_token)");

        return;
    }

    WINAPICALL_STATUS gpFetched = GetTokenInformation(hToken,
                                                      TokenGroups,
                                                      tmpGpInfo,
                                                      gpSize,
                                                      &gpSize);

    if (!gpFetched)
    {
        LocalFree(tmpGpInfo);

        errinfo->code = GetLastError();
        wcscpy_s(errinfo->winapi_func_name, WIN32API_FUNC_WLEN, L"GetTokenInformation (__get_group_token, fetch)");

        return;
    }

    gpInfo = &tmpGpInfo;
}

int __sort_search_group_name(const void *a, const void *b)
{
    LPCWCHAR aChar, bChar;

    // TODO: Reimplement

    return wcscmp(aChar, bChar);
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
    HANDLE hToken = NULL;

    __open_handle_token(&errinfo, &hToken);
    if (errinfo.code != 0)
    {
        if (hToken != NULL)
            CloseHandle(hToken);

        return errinfo;
    }

    PTOKEN_GROUPS gpInfo;
    __get_group_token(&errinfo, &hToken, &gpInfo);
    if (errinfo.code != 0)
    {
        CloseHandle(hToken);

        return errinfo;
    }

    *length = gpInfo->GroupCount;

    LocalFree(gpInfo);
    CloseHandle(hToken);

    return errinfo;
}

// Obtain user's associated group in local system.
FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO get_associated_groups(LPWSTR **groups)
{
    SUPERUSER_ERRORINFO errinfo = {0};
    HANDLE hToken = NULL;

    __open_handle_token(&errinfo, &hToken);
    if (errinfo.code != 0)
    {
        if (hToken != NULL)
            CloseHandle(hToken);

        return errinfo;
    }

    PTOKEN_GROUPS gpInfo;
    __get_group_token(&errinfo, &hToken, &gpInfo);
    if (errinfo.code != 0)
    {
        CloseHandle(hToken);

        return errinfo;
    }

    DWORD offerGroupsSize = sizeof(*groups) / sizeof((*groups)[0]);
    if (offerGroupsSize < gpInfo->GroupCount)
    {
        LocalFree(gpInfo);
        CloseHandle(hToken);

        errinfo.code = ERROR_INSUFFICIENT_BUFFER;
        wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"<internal> (get_associated_groups)");

        return errinfo;
    }

    return errinfo;
}

// Verify user who execute program has admin right.
FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO is_admin_user(bool *result)
{
    SUPERUSER_ERRORINFO errinfo = {0};
    HANDLE hToken = NULL;

    __open_handle_token(&errinfo, &hToken);
    if (errinfo.code != 0)
    {
        if (hToken != NULL)
            CloseHandle(hToken);

        return errinfo;
    }

    TOKEN_ELEVATION_TYPE elevateType;
    DWORD cbSize = 0;

    WINAPICALL_STATUS hasInfo = GetTokenInformation(hToken,
                                                    TokenElevationType,
                                                    &elevateType,
                                                    sizeof(elevateType),
                                                    &cbSize);

    if (!hasInfo)
    {
        CloseHandle(hToken);

        errinfo.code = GetLastError();
        wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"GetTokenInformation (is_admin_user)");

        return errinfo;
    }

    if (elevateType == TokenElevationTypeFull ||
        elevateType == TokenElevationTypeLimited)
    {
        /* Appearly this user run with prove of admin right already. */
        *result = true;

        CloseHandle(hToken);

        return errinfo;
    }

    /* Fallback approach when the one-shot test yield failed */

    SID_IDENTIFIER_AUTHORITY ntAuth = SECURITY_NT_AUTHORITY;
    PSID adminGp = NULL;
    WINAPICALL_STATUS fallbackAdminInit = AllocateAndInitializeSid(&ntAuth,
                                                                   2,
                                                                   SECURITY_BUILTIN_DOMAIN_RID,
                                                                   DOMAIN_ALIAS_RID_ADMINS,
                                                                   0, 0, 0, 0, 0, 0,
                                                                   &adminGp);

    if (!fallbackAdminInit)
    {
        CloseHandle(hToken);

        errinfo.code = GetLastError();
        wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"AllocateAndInitializeSid (is_admin_user)");

        return errinfo;
    }

    WINAPICALL_STATUS fallbackAdminCheck = CheckTokenMembership(NULL,
                                                                adminGp,
                                                                result);

    if (!fallbackAdminCheck)
    {
        errinfo.code = GetLastError();
        wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"CheckTokenMembership (is_admin_user)");
    }

    FreeSid(adminGp);
    CloseHandle(hToken);
    return errinfo;
}

// Determine this program is executed with admin.
FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO is_elevated(bool *result)
{
    SUPERUSER_ERRORINFO errinfo = {0};
    HANDLE hToken = NULL;

    __open_handle_token(&errinfo, &hToken);
    if (errinfo.code != 0)
    {
        if (hToken != NULL)
            CloseHandle(hToken);

        return errinfo;
    }

    TOKEN_ELEVATION elevation;
    DWORD cbSize = 0;

    WINAPICALL_STATUS hasInfo = GetTokenInformation(hToken,
                                                    TokenElevation,
                                                    &elevation,
                                                    sizeof(elevation),
                                                    &cbSize);
    if (!hasInfo)
    {
        CloseHandle(hToken);

        errinfo.code = GetLastError();
        wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"GetTokenInformation (is_elevated)");

        return errinfo;
    }

    *result = elevation.TokenIsElevated ? true : false;

    CloseHandle(hToken);

    return errinfo;
}
