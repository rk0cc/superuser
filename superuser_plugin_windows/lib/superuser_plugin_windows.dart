/// A nested library to implement [SuperuserPlatform] for Windows.
library;

import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:superuser_interfaces/superuser_interfaces.dart';

import 'src/win_superuser.g.dart';

typedef _OutWCharString = ffi.Pointer<ffi.WChar>;
typedef _OutWCharStringPointer = ffi.Pointer<_OutWCharString>;

/// Enquire superuser status and user information in Windows platform.
final class WindowsSuperuser extends SuperuserPlatform {
  /// Create new instance of [WindowsSuperuser].
  /// 
  /// Attempt to construct it in non-Windows platform will throws
  /// [UnsupportedError] instantly.
  WindowsSuperuser() {
    if (!Platform.isWindows) {
      throw UnsupportedError("This platform only designed for Windows platform.");
    }
  }

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

  OSString get _localMachineName {
    _OutWCharString mnameBuf = calloc<ffi.WChar>(NETBIOS_NAME_LEN);
    _OutWCharStringPointer mbPtr = calloc<_OutWCharString>()..value = mnameBuf;

    try {
      SUPERUSER_ERRORINFO errInfo = get_local_machine_name(mbPtr);

      if (errInfo.code != 0) {
        calloc.free(mnameBuf);

        throw SuperuserProcessError(
          errorCode: errInfo.code,
          functionName: (
            entryPoint: "_localMachineName",
            nativeAPI: _fixedWCharArrayToString(errInfo.winapi_func_name),
          ),
          message: "Unable to extract local machine name.",
        );
      }
    } finally {
      calloc.free(mbPtr);
    }

    late String mname;

    try {
      mname = mnameBuf.cast<Utf16>().toDartString();
    } finally {
      calloc.free(mnameBuf);
    }

    return OSString.allCapital(mname);
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

    final OSStringsSet localDomains = OSStringsSet()
      ..add(OSString.allCapital("BUILTIN"))
      ..add(_localMachineName);

    ffi.Pointer<WINDOWS_GROUP_NAME> groupsPtr = calloc<WINDOWS_GROUP_NAME>(
      groupLength,
    );
    ffi.Pointer<ffi.Pointer<WINDOWS_GROUP_NAME>> gpsEnvelopPtr =
        calloc<ffi.Pointer<WINDOWS_GROUP_NAME>>()..value = groupsPtr;

    try {
      SUPERUSER_ERRORINFO errInfo = get_associated_groups(gpsEnvelopPtr);

      if (errInfo.code != 0) {
        calloc.free(groupsPtr);

        throw SuperuserProcessError(
          errorCode: errInfo.code,
          functionName: (
            entryPoint: "_groupsGenerator()",
            nativeAPI: _fixedWCharArrayToString(errInfo.winapi_func_name),
          ),
          message: "Cannot extract groups information.",
        );
      }
    } finally {
      calloc.free(gpsEnvelopPtr);
    }

    try {
      for (int cursor = 0; cursor < groupLength; cursor++) {
        WINDOWS_GROUP_NAME gp = groupsPtr[cursor];

        String domainName = _fixedWCharArrayToString(gp.domain);

        if (localDomains.any((g) => g <= domainName.toUpperCase())) {
          yield _fixedWCharArrayToString(gp.name);
        }
      }
    } finally {
      calloc.free(groupsPtr);
    }
  }

  @override
  OSStringsSet get groups => OSStringsSet.unmodifiable(
    OSStringsSet.fromStrings(_groupsGenetator(), OSString.MATCH_CAPITAL),
  );
}
