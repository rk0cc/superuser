#include <errno.h>
#include <grp.h>
#include <pwd.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>

#include "superuser_plugin_unix.h"

#define ROOT_UID 0

typedef enum _error_causes
{
    pwuid_err = 1,
    grnam_err = 2,
    grouplist_err = 3
} error_causes;

static ERRCODE __build_suunix_error_code(error_causes causes, int error_code)
{
    return (causes << 16) | error_code;
}

// Common method to obtain current user structure.
void __get_current_user_info(struct passwd** pw)
{
    uid_t uid = geteuid();
    *pw = getpwuid(uid);
}

// Determine user who execute this program is root.
FFI_PLUGIN_EXPORT bool is_root()
{
    return geteuid() == ROOT_UID;
}

// Determine user is a group member, which eligable to execute program as root by calling
// sudo command.
//
// This method requires sudo bundled in OS already. Normally, majority of UNIX or liked
// system.
FFI_PLUGIN_EXPORT ERRCODE is_sudo_group(bool* result)
{
    *result = false;

    struct passwd* pw;
    errno = 0;
    __get_current_user_info(&pw);

    if (!pw)
        return __build_suunix_error_code(pwuid_err, errno);

    char* sudo_gpname;
    struct group *gp;

#if defined(__APPLE__) && defined(__MACH__)
    sudo_gpname = "admin";
#else
    sudo_gpname = "sudo";
#endif

    errno = 0;
    gp = getgrnam(sudo_gpname);
    if (!gp)
    {
        return errno > 0 ? __build_suunix_error_code(grnam_err, errno) : 0;
    }

    gid_t sudo_gpid = gp->gr_gid;

    int ngps = 0;
    getgrouplist(pw->pw_name, pw->pw_gid, NULL, &ngps);
    gid_t* gp_lists = (gid_t*) calloc(ngps, sizeof(gid_t));

    errno = 0;
    getgrouplist(pw->pw_name, pw->pw_gid, gp_lists, &ngps);
    if (errno > 0)
        return __build_suunix_error_code(grouplist_err, errno);

    for (int i = 0; i < ngps; i++)
    {
        if (gp_lists[i] == sudo_gpid)
        {
            *result = true;
            break;
        }
    }

    free(gp_lists);

    return 0;
}

// Obtain name of user.
FFI_PLUGIN_EXPORT ERRCODE get_uname(char** result)
{
    struct passwd* pw;
    errno = 0;
    __get_current_user_info(&pw);

    if (!pw)
        return __build_suunix_error_code(pwuid_err, errno);

    *result = pw->pw_name;

    return 0;
}
