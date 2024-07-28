import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart' as ffi;
import 'package:superuser_interfaces/superuser_interfaces.dart';

import 'superuser_plugin_unix_bindings_generated.dart';

const String _libName = 'superuser_plugin_unix';

/// Define [SuperuserInterface] under UNIX environment.
///
/// Remark: [isActivated] is identical with [isSuperuser]
/// since `root` is a definition of superuser.
final class UnixSuperuser extends SuperuserPlatform {
  UnixSuperuser()
      : super(() {
          if (Platform.isMacOS) {
            return DynamicLibrary.open('$_libName.framework/$_libName');
          }

          if (Platform.isLinux) {
            return DynamicLibrary.open('lib$_libName.so');
          }

          throw UnsupportedError(
              'Unknown platform: ${Platform.operatingSystem}');
        });

  @override
  bool get isActivated =>
      onGettingProperties((lib) => SuperuserPluginUnixBindings(lib).is_root());

  @override
  bool get isSuperuser {
    if (isActivated) {
      return true;
    }

    return onGettingProperties((lib) {
      final SuperuserPluginUnixBindings bindings =
          SuperuserPluginUnixBindings(lib);

      Pointer<Bool> result = ffi.calloc<Bool>();

      try {
        int errCode = bindings.is_sudo_group(result);

        if (errCode > 0) {
          throw SuperuserProcessError(
              errCode, "Unable to retrive group information.");
        }

        return result.value;
      } finally {
        ffi.calloc.free(result);
      }
    });
  }

  @override
  String get whoAmI => onGettingProperties((lib) {
        final SuperuserPluginUnixBindings bindings =
            SuperuserPluginUnixBindings(lib);

        Pointer<Pointer<Char>> resultPtr = ffi.calloc<Pointer<Char>>();

        try {
          int errCode = bindings.get_uname(resultPtr);

          if (errCode > 0) {
            throw SuperuserProcessError(errCode, "Unable to retrive username.");
          }

          String result = resultPtr.value.cast<ffi.Utf8>().toDartString();

          return result;
        } finally {
          ffi.calloc.free(resultPtr);
        }
      });

  @override
  Iterable<String> get groups => onGettingProperties((lib) sync* {
    final SuperuserPluginUnixBindings bindings = SuperuserPluginUnixBindings(lib);

    Pointer<Pointer<Pointer<Char>>> gps = ffi.calloc<Pointer<Pointer<Char>>>();
    Pointer<Int> size = ffi.calloc<Int>();

    try {
      int errCode = bindings.get_groups(size, gps);
      if (errCode > 0) {
        throw SuperuserProcessError(errCode, "Unable to obtain current user's associated groups.");
      }

      Pointer<Pointer<Char>> gpPtrArr = gps.value;

      try {
        for (int i = 0; i < size.value; i++) {
          yield gpPtrArr[i].cast<ffi.Utf8>().toDartString();
        }
      } finally {
        bindings.flush(gpPtrArr.cast<Void>());
      }
    } finally {
      [gps, size].forEach(ffi.calloc.free);
    }
  });
}
