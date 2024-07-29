#ifndef FLUTTER_SUPERUSER_UNIX_H
#define FLUTTER_SUPERUSER_UNIX_H

#include <stdbool.h>
#include <sys/types.h>

#define FFI_PLUGIN_EXPORT

typedef unsigned int ERRCODE;

// Obtain name of user.
FFI_PLUGIN_EXPORT ERRCODE get_uname(char **result);

// Obtain all associated group for current user.
FFI_PLUGIN_EXPORT ERRCODE get_current_user_group(int *size, gid_t **groups);

// Resolve name of group from given ID number.
FFI_PLUGIN_EXPORT ERRCODE get_group_name_by_gid(gid_t group_id, char** result);

// Determine user who execute this program is root.
FFI_PLUGIN_EXPORT bool is_root();

// Determine user is a group member, which eligable to execute program as root by calling
// sudo command.
//
// This method requires sudo bundled in OS already. Normally, majority of UNIX or liked
// system.
FFI_PLUGIN_EXPORT ERRCODE is_sudo_group(bool *result);

// Flush dynamic allocated pointers.
FFI_PLUGIN_EXPORT void flush(void *ptr);

#endif