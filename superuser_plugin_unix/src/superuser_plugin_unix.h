#ifndef FLUTTER_SUPERUSER_UNIX_H
#define FLUTTER_SUPERUSER_UNIX_H

#include <stdbool.h>

#define FFI_PLUGIN_EXPORT

// Replicate GNU C library's error_t type
#ifndef __error_t_defined
#define __error_t_defined 1

typedef int error_t;

#endif

// Determine user who execute this program is root.
FFI_PLUGIN_EXPORT bool is_root();

// Determine user is a group member, which eligable to execute program as root by calling
// sudo command.
//
// This method requires sudo bundled in OS already. Normally, majority of UNIX or liked
// system.
FFI_PLUGIN_EXPORT error_t is_sudo_group(bool* result);

// Obtain name of user.
FFI_PLUGIN_EXPORT error_t get_uname(char** result);

#endif