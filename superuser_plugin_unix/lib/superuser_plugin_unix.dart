/// [SuperuserPlatform] in UNIX (POSIX) implementations.
library;

import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:superuser_interfaces/superuser_interfaces.dart';

import 'src/unix_superuser.g.dart';

/// Define [SuperuserInterface] under UNIX environment with POSIX C
/// API implementation.
///
/// Remark: [isActivated] is identical with [isSuperuser]
/// since `root` is a definition of superuser.
final class UnixSuperuser extends SuperuserPlatform {
  UnixSuperuser() {
    if (!(Platform.isLinux || Platform.isMacOS)) {
      throw UnsupportedError(
        "This platform only designed for UNIX (POSIX) platform.",
      );
    }
  }

  static String _fixedCharArrayToString(ffi.Array<ffi.Char> array) {
    final chars = Uint8List.fromList(array.elements);
    final nullIndex = chars.indexWhere((c) => c == 0);

    if (nullIndex == -1) {
      throw RangeError("Null terminated does not exist in character array.");
    }

    return utf8.decode(chars.sublist(0, nullIndex + 1));
  }

  @override
  bool get isActivated => is_root();

  @override
  bool get isSuperuser {
    if (isActivated) {
      return true;
    }

    ffi.Pointer<ffi.Bool> result = calloc<ffi.Bool>();

    try {
      SUPERUSER_ERRINFO errInfo = is_sudo_group(result);

      if (errInfo.code != 0) {
        throw SuperuserProcessError(
          errorCode: errInfo.code,
          functionName: (
            entryPoint: "isSuperuser",
            nativeAPI: _fixedCharArrayToString(errInfo.unixapi_func_name),
          ),
          message: "Unable to retrive group information.",
        );
      }

      return result.value;
    } finally {
      calloc.free(result);
    }
  }

  @override
  OSString get whoAmI {
    ffi.Pointer<ffi.Pointer<ffi.Char>> resultPtr =
        calloc<ffi.Pointer<ffi.Char>>();

    try {
      SUPERUSER_ERRINFO errInfo = get_uname(resultPtr);

      if (errInfo.code > 0) {
        throw SuperuserProcessError(
          errorCode: errInfo.code,
          functionName: (
            entryPoint: "whoAmI",
            nativeAPI: _fixedCharArrayToString(errInfo.unixapi_func_name),
          ),
          message: "Unable to retrive username.",
        );
      }

      return OSString.caseSensitive(
        resultPtr.value.cast<Utf8>().toDartString(),
      );
    } finally {
      calloc.free(resultPtr);
    }
  }

  Iterable<String> _groupGenerator() sync* {
    ffi.Pointer<ffi.Pointer<gid_t>> gps = calloc<ffi.Pointer<gid_t>>();
    ffi.Pointer<ffi.Int> size = calloc<ffi.Int>();

    late ffi.Pointer<gid_t> gids;
    late int gpSize;

    try {
      SUPERUSER_ERRINFO errInfo = get_current_user_group(size, gps);
      if (errInfo.code > 0) {
        throw SuperuserProcessError(
          errorCode: errInfo.code,
          functionName: (
            entryPoint: "_groupGenerator",
            nativeAPI: _fixedCharArrayToString(errInfo.unixapi_func_name),
          ),
          message: "Unable to obtain current user's associated groups.",
        );
      }

      gids = gps.value;
      gpSize = size.value;
    } finally {
      [gps, size].forEach(calloc.free);
    }

    ffi.Pointer<ffi.Pointer<ffi.Char>> gpNamePtr =
        calloc<ffi.Pointer<ffi.Char>>();

    try {
      for (int i = 0; i < gpSize; i++) {
        SUPERUSER_ERRINFO nameErrInfo = get_group_name_by_gid(
          gids[i],
          gpNamePtr,
        );

        if (nameErrInfo.code != 0) {
          throw SuperuserProcessError(
            errorCode: nameErrInfo.code,
            functionName: (
              entryPoint: "_groupGenerator",
              nativeAPI: _fixedCharArrayToString(nameErrInfo.unixapi_func_name),
            ),
            message: "Failed to list group name.",
          );
        }

        yield gpNamePtr.value.cast<Utf8>().toDartString();
      }
    } finally {
      calloc.free(gpNamePtr);
      flush_group(gids);
    }
  }

  @override
  OSStringsSet get groups => OSStringsSet.unmodifiable(
    OSStringsSet.fromStrings(
      _groupGenerator(),
      OSString.MATCH_CAPITAL | OSString.MATCH_SMALL,
    ),
  );
}
