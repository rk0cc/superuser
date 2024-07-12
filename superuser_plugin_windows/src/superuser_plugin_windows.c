#include <stdlib.h>

#include "superuser_plugin_windows.h"

#define MAX_USERNAME_CHAR 257
#define MAX_USERNAME_CHAR8 769

// Verify user who execute program has admin right.
FFI_PLUGIN_EXPORT bool is_admin_user()
{
    BOOL admin;
    SID_IDENTIFIER_AUTHORITY ntAuth = SECURITY_NT_AUTHORITY;
    PSID adminGP;

    admin = AllocateAndInitializeSid(
        &ntAuth,
        2,
        SECURITY_BUILTIN_DOMAIN_RID,
        DOMAIN_ALIAS_RID_ADMINS,
        0, 0, 0, 0, 0, 0,
        &adminGP
    );

    if (admin)
    {
        if (!CheckTokenMembership(NULL, adminGP, &admin))
        {
            admin = FALSE;
        }

        FreeSid(adminGP);
    }

    return admin;
}

// Determine this program is executed with admin.
FFI_PLUGIN_EXPORT bool is_elevated()
{
    BOOL ret = FALSE;
    HANDLE token = NULL;

    if (OpenProcessToken(
        GetCurrentProcess(),
        TOKEN_QUERY,
        &token
    ))
    {
        TOKEN_ELEVATION elevation;
        DWORD cbSize = sizeof(TOKEN_ELEVATION);

        if (GetTokenInformation(
            token, 
            TokenElevation, 
            &elevation,
            sizeof elevation,
            &cbSize
        ))
        {
            ret = elevation.TokenIsElevated;
        }
    }

    if (token)
    {
        CloseHandle(token);
    }

    return ret;
}

// Obtain name of user.
FFI_PLUGIN_EXPORT char* get_current_username()
{
    WCHAR buffer[MAX_USERNAME_CHAR];
    DWORD bufLen = MAX_USERNAME_CHAR;

    if (!GetUserNameW(buffer, &bufLen))
        return "<Unknown username>";

    char* buffer8[MAX_USERNAME_CHAR8];

    WideCharToMultiByte(CP_UTF8, 0, buffer, -1, buffer8, MAX_USERNAME_CHAR8, NULL, NULL);

    return buffer8;
}
