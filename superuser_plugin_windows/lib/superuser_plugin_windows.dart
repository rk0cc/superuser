import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:superuser_interfaces/superuser_interfaces.dart';

import 'src/win_superuser.g.dart';

typedef _OutWCharString = ffi.Pointer<ffi.WChar>;
typedef _OutWCharStringPointer = ffi.Pointer<_OutWCharString>;
typedef _OutWCharString2DPointer = ffi.Pointer<_OutWCharStringPointer>;

/// Construct [SuperuserInterface] based on Windows API.
final class WindowsSuperuser extends SuperuserPlatform {
  WindowsSuperuser() : assert(Platform.isWindows);

  static String _fixedWCharArrayToString(ffi.Array<ffi.WChar> array) {
    final chars = Uint16List.fromList(array.elements);
    final nullIndex = chars.indexWhere((c) => c == 0);

    if (nullIndex == -1) {
      throw RangeError("Null terminated does not exist in character array.");
    }

    return String.fromCharCodes(chars, 0, nullIndex);
  }

  @override
  bool get isActivated {
    ffi.Pointer<ffi.Bool> result = calloc<ffi.Bool>();

    try {
      SUPERUSER_ERRORINFO errInfo = is_elevated(result);

      if (errInfo.code != 0) {
        throw SuperuserProcessError(
          errorCode: errInfo.code,
          functionName: (
            entryPoint: "isActivated",
            nativeAPI: _fixedWCharArrayToString(errInfo.winapi_func_name),
          ),
          message: "Cannot determine superuser activation status.",
        );
      }

      return result.value;
    } finally {
      calloc.free(result);
    }
  }

  @override
  bool get isSuperuser {
    ffi.Pointer<ffi.Bool> result = calloc<ffi.Bool>();

    try {
      SUPERUSER_ERRORINFO errInfo = is_elevated(result);

      if (errInfo.code != 0) {
        throw SuperuserProcessError(
          errorCode: errInfo.code,
          functionName: (
            entryPoint: "isSuperuser",
            nativeAPI: _fixedWCharArrayToString(errInfo.winapi_func_name),
          ),
          message: "Cannot determine superuser activation status.",
        );
      }

      return result.value;
    } finally {
      calloc.free(result);
    }
  }

  @override
  OSString get whoAmI {
    _OutWCharString unameBuf = calloc<ffi.WChar>(MAX_USERNAME_CHAR);
    _OutWCharStringPointer ubPtr = calloc<_OutWCharString>()..value = unameBuf;

    try {
      SUPERUSER_ERRORINFO errInfo = get_current_username(ubPtr);

      if (errInfo.code != 0) {
        calloc.free(unameBuf);

        throw SuperuserProcessError(
          errorCode: errInfo.code,
          functionName: (
            entryPoint: "whoAmI",
            nativeAPI: _fixedWCharArrayToString(errInfo.winapi_func_name),
          ),
          message: "Unable to extract current username.",
        );
      }
    } finally {
      calloc.free(ubPtr);
    }

    late String uname;

    try {
      uname = unameBuf.cast<Utf16>().toDartString();
    } finally {
      calloc.free(unameBuf);
    }

    return OSString.allCapital(uname);
  }

  Iterable<String> _groupsGenetator() sync* {
    ffi.Pointer<ffi.UnsignedLong> groupLengthPtr = calloc<ffi.UnsignedLong>();
    late int groupLength;

    try {
      SUPERUSER_ERRORINFO errInfo = count_associated_groups_length(
        groupLengthPtr,
      );

      if (errInfo.code != 0) {
        throw SuperuserProcessError(
          errorCode: errInfo.code,
          functionName: (
            entryPoint: "_groupsGenerator",
            nativeAPI: _fixedWCharArrayToString(errInfo.winapi_func_name),
          ),
          message: "An error occured when initializing group name extraction.",
        );
      }

      groupLength = groupLengthPtr.value;
    } finally {
      calloc.free(groupLengthPtr);
    }

    _OutWCharStringPointer groupNamesPtr = calloc<_OutWCharString>(groupLength);
    for (int groupIndex = 0; groupIndex < groupLength; groupIndex++) {
      groupNamesPtr[groupIndex] = calloc<ffi.WChar>(MAX_USERNAME_CHAR);
    }

    _OutWCharString2DPointer groupsPtr = calloc<_OutWCharStringPointer>()
      ..value = groupNamesPtr;

    try {
      SUPERUSER_ERRORINFO errInfo = get_associated_groups(groupsPtr);

      if (errInfo.code != 0) {
        for (int i = 0; i < groupLength; i++) {
          calloc.free(groupNamesPtr[i]);
        }
        calloc.free(groupNamesPtr);

        throw SuperuserProcessError(
          errorCode: errInfo.code,
          functionName: (
            entryPoint: "_groupsGenerator",
            nativeAPI: _fixedWCharArrayToString(errInfo.winapi_func_name),
          ),
          message: "Cannot extract groups information.",
        );
      }
    } finally {
      calloc.free(groupsPtr);
    }

    int cursor = 0;
    try {
      for (; cursor < groupLength; cursor++) {
        ffi.Pointer<Utf16> groupNameStr = groupNamesPtr[cursor].cast<Utf16>();

        yield groupNameStr.toDartString();

        calloc.free(groupNameStr);
      }
    } finally {
      for (; cursor < groupLength; cursor++) {
        calloc.free(groupNamesPtr[cursor]);
      }
      calloc.free(groupNamesPtr);
    }
  }

  @override
  OSStringsSet get groups =>
      OSStringsSet.fromStrings(_groupsGenetator(), OSString.MATCH_CAPITAL);
}
