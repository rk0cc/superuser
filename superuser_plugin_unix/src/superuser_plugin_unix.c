#include <errno.h>
#include <pwd.h>
#include <unistd.h>

#include "superuser_plugin_unix.h"

#define ROOT_UID 0
#define UID __uid_t

// Determine user who execute this program is root.
FFI_PLUGIN_EXPORT bool is_root()
{
    return geteuid() == ROOT_UID;
}

// Obtain name of user.
FFI_PLUGIN_EXPORT int get_uname(char** result)
{
    errno = 0;

    struct passwd *pw;
    UID uid = geteuid();

    pw = getpwuid(uid);
    if (!pw)
        return errno;
        

    *result = pw->pw_name;

    return 0;
}
