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
#define DEFAULT_UNIX_SUDO_GP "sudo"
#endif
#endif

typedef enum _error_causes
{
    pwuid_err = 1,
    grnam_err,
    grouplist_err,
    grgid_err
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

void __get_pw_groups(struct passwd *pw, int *length, gid_t **groups)
{
    int ngps;
    long max_ngps = sysconf(_SC_NGROUPS_MAX) + 1;
    gid_t *tmp_groups = (gid_t *)calloc(max_ngps, sizeof(gid_t));

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
FFI_PLUGIN_EXPORT ERRCODE get_uname(char **result)
{
    struct passwd *pw;
    errno = 0;
    __get_current_user_info(&pw);

    if (!pw)
        return __build_suunix_error_code(pwuid_err, errno);

    char *username = pw->pw_name;
    *result = username;

    return 0;
}

// Obtain all associated group for current user.
FFI_PLUGIN_EXPORT ERRCODE get_current_user_group(int *size, gid_t **groups)
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
    if (ngps == -1 || errno > 0)
    {
        free(gp_lists);
        return __build_suunix_error_code(grouplist_err, errno);
    }

    *size = ngps;
    *groups = gp_lists;

    return 0;
}

// Resolve name of group from given ID number.
FFI_PLUGIN_EXPORT ERRCODE get_group_name_by_gid(gid_t group_id, char **result)
{
    errno = 0;
    struct group* gp = getgrgid(group_id);
    if (!gp)
        return __build_suunix_error_code(grgid_err, errno);

    *result = gp->gr_name;

    return 0;
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

    gid_t *gp_lists;
    int ngps;
    ERRCODE gp_list_err = get_current_user_group(&ngps, &gp_lists);

    if (gp_list_err > 0)
        return gp_list_err;

    qsort(gp_lists, ngps, sizeof(gid_t), __sort_search_gid_compare);
    gid_t *found = (gid_t *)bsearch(&sudo_gpid, gp_lists, ngps, sizeof(gid_t), __sort_search_gid_compare);

    *result = found != NULL;

    free(gp_lists);

    return 0;
}

// Flush dynamic allocated pointers.
FFI_PLUGIN_EXPORT void flush(void *ptr)
{
    free(ptr);
}
