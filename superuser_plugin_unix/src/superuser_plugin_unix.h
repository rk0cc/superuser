#ifndef FLUTTER_SUPERUSER_UNIX_H
#define FLUTTER_SUPERUSER_UNIX_H

#if !defined(__STDC_VERSION__) || __STDC_VERSION__ < 202311L
#include <stdbool.h>
#endif

#ifdef __cplusplus
extern "C"
{
#endif
#include <sys/types.h>

#define MAX_UNIX_FUNCNAME_LEN 129
#define FFI_PLUGIN_EXPORT

    // Type of error code
    typedef unsigned int ERRCODE;

    // A well-defined structure to represent error information in UNIX
    typedef struct _SUPERUSER_ERRINFO
    {
        ERRCODE code;
        char unixapi_func_name[MAX_UNIX_FUNCNAME_LEN];
    } SUPERUSER_ERRINFO;

    // Obtain name of user.
    FFI_PLUGIN_EXPORT SUPERUSER_ERRINFO get_uname(char **result);

    // Obtain all associated group for current user.
    FFI_PLUGIN_EXPORT SUPERUSER_ERRINFO get_current_user_group(int *size, gid_t **groups);

    // Resolve name of group from given ID number.
    FFI_PLUGIN_EXPORT SUPERUSER_ERRINFO get_group_name_by_gid(gid_t group_id, char **result);

    // Determine user who execute this program is root.
    FFI_PLUGIN_EXPORT bool is_root();

    // Determine user is a group member, which eligable to execute program as root by calling
    // sudo command.
    //
    // This method requires sudo bundled in OS already. Normally, majority of UNIX or liked
    // system.
    FFI_PLUGIN_EXPORT SUPERUSER_ERRINFO is_sudo_group(bool *result);

    // Flush dynamic allocated group pointers.
    FFI_PLUGIN_EXPORT void flush_group(gid_t *groups);

#ifdef __cplusplus
}
#endif

#endif