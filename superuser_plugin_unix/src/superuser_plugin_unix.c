#include <errno.h>
#include <grp.h>
#include <pwd.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>

#include "superuser_plugin_unix.h"

#define ROOT_UID 0

#ifndef DEFAULT_UNIX_SUDO_GP
#if defined(__APPLE__) && defined(__MACH__)
#define DEFAULT_UNIX_SUDO_GP "admin"
#else
#define DEFAULT_UNIX_SUDO_GP "sudo"
#endif
#endif

typedef enum _error_causes
{
    pwuid_err = 1,
    grnam_err = 2,
    grouplist_err = 3,
    grgid_err = 4
} error_causes;

static ERRCODE __build_suunix_error_code(error_causes causes, int error_code)
{
    return (causes << 16) | error_code;
}

// Common method to obtain current user structure.
void __get_current_user_info(struct passwd **pw)
{
    uid_t uid = geteuid();
    *pw = getpwuid(uid);
}

void __get_pw_groups(struct passwd* pw, int *length, gid_t **groups)
{
    int ngps;
    getgrouplist(pw->pw_name, pw->pw_gid, NULL, &ngps);
    *length = ngps;

    gid_t *tmp_groups = (gid_t *)calloc(ngps, sizeof(gid_t));
    getgrouplist(pw->pw_name, pw->pw_gid, tmp_groups, &ngps);
    *groups = tmp_groups;
}

int __sort_search_gid_compare(const void *a, const void *b)
{
    return (*(gid_t *)a - *(gid_t *)b);
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
FFI_PLUGIN_EXPORT ERRCODE is_sudo_group(bool *result)
{
    char *sudo_gpname = DEFAULT_UNIX_SUDO_GP;
    struct group *gp;

    errno = 0;
    gp = getgrnam(sudo_gpname);
    if (!gp)
        return errno > 0 ? __build_suunix_error_code(grnam_err, errno) : 0;

    // As key of bsearch
    gid_t sudo_gpid = gp->gr_gid;

    struct passwd *pw;
    errno = 0;
    __get_current_user_info(&pw);

    if (!pw)
        return __build_suunix_error_code(pwuid_err, errno);

    int ngps;
    gid_t *gp_lists;
    errno = 0;
    __get_pw_groups(pw, &ngps, &gp_lists);
    if (errno > 0)
        return __build_suunix_error_code(grouplist_err, errno);

    bool found = false;
    for (int i = 0; i < ngps; i++)
    {
        if (gp_lists[i] == sudo_gpid)
        {
            found = true;
            break;
        }
    }

    *result = found;

    free(gp_lists);

    return 0;
}

// Obtain name of user.
FFI_PLUGIN_EXPORT ERRCODE get_uname(char **result)
{
    struct passwd *pw;
    errno = 0;
    __get_current_user_info(&pw);

    if (!pw)
        return __build_suunix_error_code(pwuid_err, errno);

    char* username = pw->pw_name;
    *result = username;

    return 0;
}

// Obtain all associated group for current user.
FFI_PLUGIN_EXPORT ERRCODE get_groups(int *size, char ***groups)
{
    struct passwd *pw;
    errno = 0;
    __get_current_user_info(&pw);

    if (!pw)
        return __build_suunix_error_code(pwuid_err, errno);

    int ngps;
    gid_t *gp_lists;
    errno = 0;
    __get_pw_groups(pw, &ngps, &gp_lists);
    if (errno > 0)
        return __build_suunix_error_code(grouplist_err, errno);

    char **user_gpnames = calloc(ngps, sizeof(char *));

    for (int i = 0; i < ngps; i++)
    {
        errno = 0;
        struct group *gp = getgrgid(gp_lists[i]);

        if (errno > 0)
        {
            free(user_gpnames);
            free(gp_lists);
            return __build_suunix_error_code(grgid_err, errno);
        }

        user_gpnames[i] = gp->gr_name;
    }

    *size = ngps;
    *groups = user_gpnames;

    free(gp_lists);

    return 0;
}

// Flush dynamic allocated pointers.
FFI_PLUGIN_EXPORT void flush(void *ptr)
{
    free(ptr);
}
