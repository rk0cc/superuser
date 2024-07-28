#ifndef FLUTTER_SUPERUSER_UNIX_H
#define FLUTTER_SUPERUSER_UNIX_H

#include <stdbool.h>

#define FFI_PLUGIN_EXPORT

typedef unsigned int ERRCODE;

// Determine user who execute this program is root.
FFI_PLUGIN_EXPORT bool is_root();

// Determine user is a group member, which eligable to execute program as root by calling
// sudo command.
//
// This method requires sudo bundled in OS already. Normally, majority of UNIX or liked
// system.
FFI_PLUGIN_EXPORT ERRCODE is_sudo_group(bool *result);

// Obtain name of user.
FFI_PLUGIN_EXPORT ERRCODE get_uname(char **result);

// Obtain all associated group for current user.
FFI_PLUGIN_EXPORT ERRCODE get_groups(int *size, char ***groups);

// Flush dynamic allocated pointers.
FFI_PLUGIN_EXPORT void flush(void *ptr);

#endif