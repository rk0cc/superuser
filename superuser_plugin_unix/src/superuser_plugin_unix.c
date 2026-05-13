#include <errno.h>
#include <grp.h>
#include <pwd.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#include "superuser_plugin_unix.h"

#define ROOT_UID 0

#ifndef DEFAULT_UNIX_SUDO_GP
#if defined(__APPLE__) && defined(__MACH__)
#define DEFAULT_UNIX_SUDO_GP "admin"
#else
#define DEFAULT_UNIX_SUDO_GP "wheel"
#endif
#endif

void __get_sudo_group_name(char *sudo_gp_name)
{
    if (access("/etc/debian_version", F_OK) != -1)
        strncpy(sudo_gp_name, "sudo", 5); // Debian based uses `sudo` as sudoer group name
    else
        strncpy(sudo_gp_name, DEFAULT_UNIX_SUDO_GP, 6); // Uses traditional name for majority OSes
}

// Common method to obtain current user structure.
void __get_current_user_info(SUPERUSER_ERRINFO *errinfo, struct passwd **pw)
{
    uid_t uid = geteuid();
    struct passwd *tmpPw;

    errno = 0;
    tmpPw = getpwuid(uid);

    if (tmpPw == NULL)
    {
        errinfo->code = errno;
        strncpy(errinfo->unixapi_func_name, "getpwuid (__get_current_user_info)", MAX_UNIX_FUNCNAME_LEN - 1);

        return;
    }

    *pw = tmpPw;
}

void __get_pw_groups(SUPERUSER_ERRINFO *errinfo, struct passwd *pw, int *length, gid_t **groups)
{
    int ngps;
    long max_ngps = sysconf(_SC_NGROUPS_MAX) + 1;

    errno = 0;
    gid_t *tmp_groups = (gid_t *)calloc(max_ngps, sizeof(gid_t));
    if (tmp_groups == NULL)
    {
        errinfo->code = errno;
        strncpy(errinfo->unixapi_func_name, "calloc (__get_pw_groups)", MAX_UNIX_FUNCNAME_LEN - 1);

        return;
    }

    ngps = getgroups(max_ngps, tmp_groups);

    *length = ngps;
    *groups = tmp_groups;
}

int __sort_search_gid_compare(const void *a, const void *b)
{
    gid_t aVal = *(gid_t *)a, bVal = *(gid_t *)b;

    return (aVal > bVal) - (aVal < bVal);
}

// Obtain name of user.
FFI_PLUGIN_EXPORT SUPERUSER_ERRINFO get_uname(char **result)
{
    SUPERUSER_ERRINFO errinfo = {0};

    struct passwd *pw;
    __get_current_user_info(&errinfo, &pw);

    if (errinfo.code == 0)
        *result = pw->pw_name;

    return errinfo;
}

// Obtain all associated group for current user.
FFI_PLUGIN_EXPORT SUPERUSER_ERRINFO get_current_user_group(int *size, gid_t **groups)
{
    SUPERUSER_ERRINFO errinfo = {0};

    struct passwd *pw;
    errno = 0;
    __get_current_user_info(&errinfo, &pw);

    if (errinfo.code != 0)
        return errinfo;

    int ngps;
    gid_t *gp_lists;
    errno = 0;
    __get_pw_groups(&errinfo, pw, &ngps, &gp_lists);
    if (ngps == -1 || errinfo.code != 0)
    {
        free(gp_lists);
        return errinfo;
    }

    *size = ngps;
    *groups = gp_lists;

    return errinfo;
}

// Resolve name of group from given ID number.
FFI_PLUGIN_EXPORT SUPERUSER_ERRINFO get_group_name_by_gid(gid_t group_id, char **result)
{
    SUPERUSER_ERRINFO errinfo = {0};

    errno = 0;
    struct group *gp = getgrgid(group_id);
    if (!gp)
    {
        errinfo.code = errno;
        strncpy(errinfo.unixapi_func_name, "getgrgid (get_group_name_by_gid)", MAX_UNIX_FUNCNAME_LEN - 1);

        return errinfo;
    }

    *result = gp->gr_name;

    return errinfo;
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
FFI_PLUGIN_EXPORT SUPERUSER_ERRINFO is_sudo_group(bool *result)
{
    SUPERUSER_ERRINFO errinfo = {0};

    char gpName[6];
    __get_sudo_group_name(gpName);

    struct group *gp;

    errno = 0;
    gp = getgrnam(gpName);
    if (!gp)
    {
        errinfo.code = errno;
        strncpy(errinfo.unixapi_func_name, "getgrnam (is_sudo_groups)", MAX_UNIX_FUNCNAME_LEN - 1);

        return errinfo;
    }

    // As key of bsearch
    gid_t sudo_gpid = gp->gr_gid;

    gid_t *gp_lists;
    int ngps;

    errinfo = get_current_user_group(&ngps, &gp_lists);
    if (errinfo.code != 0)
        return errinfo;

    qsort(gp_lists, ngps, sizeof(gid_t), __sort_search_gid_compare);
    gid_t *found = (gid_t *)bsearch(&sudo_gpid, gp_lists, ngps, sizeof(gid_t), __sort_search_gid_compare);

    *result = found != NULL;

    free(gp_lists);

    return errinfo;
}

// Flush dynamic allocated group pointers.
FFI_PLUGIN_EXPORT void flush_group(gid_t *groups)
{
    free(groups);
}
