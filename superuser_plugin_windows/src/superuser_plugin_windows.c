#include <stdlib.h>

#include "superuser_plugin_windows.h"

#define WINAPICALL_STATUS \
    SetLastError(0);      \
    BOOL

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
    WINAPICALL_STATUS hasBuf = GetTokenInformation(*hToken,
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
    *gpInfo = (PTOKEN_GROUPS)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, gpSize);
    if (*gpInfo == NULL)
    {
        errinfo->code = GetLastError();
        wcscpy_s(errinfo->winapi_func_name, WIN32API_FUNC_WLEN, L"LocalAlloc (__get_group_token)");

        return;
    }

    WINAPICALL_STATUS gpFetched = GetTokenInformation(*hToken,
                                                      TokenGroups,
                                                      *gpInfo,
                                                      gpSize,
                                                      &gpSize);

    if (!gpFetched)
    {
        HeapFree(GetProcessHeap(), 0, (LPVOID)*gpInfo);

        errinfo->code = GetLastError();
        wcscpy_s(errinfo->winapi_func_name, WIN32API_FUNC_WLEN, L"GetTokenInformation (__get_group_token, fetch)");
    }
}

int __compare_sid(const void *a, const void *b)
{
    PSID sid1 = *(PSID *)a, sid2 = *(PSID *)b;
    DWORD len1 = GetLengthSid(sid1), len2 = GetLengthSid(sid2);

    // Compare lengths difference
    int diff = (len1 > len2) - (len1 < len2);

    return diff == 0 ? memcmp(sid1, sid2, len1) : diff;
}

// Extract machine name in NetBIOS.
FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO get_local_machine_name(LPWSTR *result)
{
    SUPERUSER_ERRORINFO errinfo = {0};
    
    WCHAR comName[NETBIOS_NAME_LEN];
    DWORD bufSize = sizeof(comName) / sizeof(comName[0]);

    WINAPICALL_STATUS hasName = GetComputerNameW(comName, &bufSize);
    if (!hasName)
    {
        errinfo.code = GetLastError();
        wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"GetComputerNameW (get_local_machine_name)");

        return errinfo;
    }

    errno_t cpErr = wcscpy_s(*result, NETBIOS_NAME_LEN, comName);
    if (cpErr != ERROR_SUCCESS)
    {
        errinfo.code = cpErr;
        wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"wcscpy_s (get_local_machine_name)");
    }

    return errinfo;
}

// Obtain name of user.
FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO get_current_username(LPWSTR *result)
{
    SUPERUSER_ERRORINFO errinfo = {0};

    WCHAR ubuf[MAX_USERNAME_CHAR];
    DWORD ubufLen = sizeof(ubuf) / sizeof(ubuf[0]);

    WINAPICALL_STATUS success = GetUserNameW(ubuf, &ubufLen);
    if (!success)
    {
        errinfo.code = GetLastError();
        wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"GetUserNameW (__get_current_username)");

        return;
    }

    errno_t cpy_errno = wcscpy_s(*result, MAX_USERNAME_CHAR, ubuf);
    if (cpy_errno != ERROR_SUCCESS)
    {
        errinfo.code = cpy_errno;
        wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"wcscpy_s (__get_current_username)");
    }

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

    HeapFree(GetProcessHeap(), 0, (LPVOID)gpInfo);
    CloseHandle(hToken);

    return errinfo;
}

// Obtain user's associated group in local system.
FFI_PLUGIN_EXPORT SUPERUSER_ERRORINFO get_associated_groups(WINDOWS_GROUP_NAME **groups)
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

    DWORD gpLen = _msize(*groups) / sizeof(WINDOWS_GROUP_NAME);
    if (gpLen != gpInfo->GroupCount)
    {
        HeapFree(GetProcessHeap(), 0, (LPVOID)gpInfo);
        CloseHandle(hToken);

        errinfo.code = ERROR_INSUFFICIENT_BUFFER;
        wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"<internal> (get_associated_groups)");

        return errinfo;
    }

    for (DWORD cursor = 0; cursor < gpInfo->GroupCount; cursor++)
    {
        WCHAR gpName[MAX_USERNAME_CHAR], gpDomain[MAX_USERNAME_CHAR];
        DWORD nameLen, domainLen;
        nameLen = domainLen = sizeof(gpName) / sizeof(gpName[0]); // Both fields have the same limit of name length.
        SID_NAME_USE snu;

        PSID lookupSID = gpInfo->Groups[cursor].Sid;
        WINAPICALL_STATUS nameClawed = LookupAccountSidW(NULL,
                                                         lookupSID,
                                                         gpName,
                                                         &nameLen,
                                                         gpDomain,
                                                         &domainLen,
                                                         &snu);
        if (!nameClawed)
        {
            HeapFree(GetProcessHeap(), 0, (LPVOID)gpInfo);
            CloseHandle(hToken);

            errinfo.code = GetLastError();
            wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"LookupAccountSidW (get_associated_groups)");

            return errinfo;
        }

        errno_t cpErrs[2] = {0, 0};
        cpErrs[0] = wcscpy_s((*groups)[cursor].name, MAX_USERNAME_CHAR, gpName);
        cpErrs[1] = wcscpy_s((*groups)[cursor].domain, MAX_USERNAME_CHAR, gpDomain);

        for (int errScope = 0; errScope < 2; errScope++)
        {
            errno_t cpErrResult = cpErrs[errScope];
            if (cpErrResult != ERROR_SUCCESS)
            {
                HeapFree(GetProcessHeap(), 0, (LPVOID)gpInfo);
                CloseHandle(hToken);

                errinfo.code = cpErrResult;
                wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"wcscpy_s (get_associated_groups)");

                return errinfo;
            }
        }
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

        return errinfo; // This sould returns error code 0
    }

    /* Fallback approach when the one-shot test yield failed */

    PTOKEN_GROUPS gps;
    __get_group_token(&errinfo, &hToken, &gps);

    if (errinfo.code != 0)
    {
        CloseHandle(hToken);

        return errinfo;
    }

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
        HeapFree(GetProcessHeap(), 0, (LPVOID)gps);
        CloseHandle(hToken);

        errinfo.code = GetLastError();
        wcscpy_s(errinfo.winapi_func_name, WIN32API_FUNC_WLEN, L"AllocateAndInitializeSid (is_admin_user)");

        return errinfo;
    }

    bool tmpResult = false;
    for (DWORD cursor = 0; cursor < gps->GroupCount; cursor++)
    {
        PSID lookupSID = gps->Groups[cursor].Sid;

        tmpResult = __compare_sid(&lookupSID, &adminGp) == 0;
        if (tmpResult)
            break; // Immediate stop iteration once admin role of this user is verified.
    }

    *result = tmpResult;

    FreeSid(adminGp);
    HeapFree(GetProcessHeap(), 0, (LPVOID)gps);
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
