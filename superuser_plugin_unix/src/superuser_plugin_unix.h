#ifndef FLUTTER_SUPERUSER_UNIX_H
#define FLUTTER_SUPERUSER_UNIX_H

#include <stdbool.h>

#define FFI_PLUGIN_EXPORT

// Determine user who execute this program is root.
FFI_PLUGIN_EXPORT bool is_root();

// Obtain name of user.
FFI_PLUGIN_EXPORT char* get_uname();

#endif