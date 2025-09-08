import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart' as ffi;
import 'package:superuser_interfaces/superuser_interfaces.dart';

import 'superuser_plugin_windows_bindings_generated.dart';

const String _libName = 'superuser_plugin_windows';

/// Construct [SuperuserInterface] based on Windows API.
final class WindowsSuperuser extends SuperuserPlatform {
  WindowsSuperuser()
    : super(() {
        if (Platform.isWindows) {
          return DynamicLibrary.open('$_libName.dll');
        }

        throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
      });

  @override
  bool get isActivated => onGettingProperties((lib) {
    final SuperuserPluginWindowsBindings bindings =
        SuperuserPluginWindowsBindings(lib);

    Pointer<Bool> result = ffi.calloc<Bool>();

    try {
      int errCode = bindings.is_elevated(result);

      if (errCode != 0) {
        throw SuperuserProcessError(
          errCode,
          "Cannot determine superuser activation status.",
        );
      }

      return result.value;
    } finally {
      ffi.calloc.free(result);
    }
  });

  @override
  bool get isSuperuser => onGettingProperties((lib) {
    final SuperuserPluginWindowsBindings bindings =
        SuperuserPluginWindowsBindings(lib);

    Pointer<Bool> result = ffi.calloc<Bool>();

    try {
      int errCode = bindings.is_admin_user(result);

      if (errCode != 0) {
        throw SuperuserProcessError(
          errCode,
          "Unable to retrive user's superuser role.",
        );
      }

      return result.value;
    } finally {
      ffi.calloc.free(result);
    }
  });

  @override
  String get whoAmI => onGettingProperties((lib) {
    final SuperuserPluginWindowsBindings binding =
        SuperuserPluginWindowsBindings(lib);

    Pointer<WChar> unameBuf = ffi.calloc(MAX_USERNAME_CHAR);
    Pointer<Pointer<WChar>> ubPtr = ffi.calloc()..value = unameBuf;

    try {
      int errCode = binding.get_current_username(ubPtr);

      if (errCode != 0) {
        ffi.calloc.free(unameBuf);

        throw SuperuserProcessError(
          errCode,
          "Unable to extract current username.",
        );
      }
    } finally {
      ffi.calloc.free(ubPtr);
    }

    try {
      Pointer<ffi.Utf16> uname = unameBuf.cast<ffi.Utf16>();

      return uname.toDartString();
    } finally {
      ffi.calloc.free(unameBuf);
    }
  });

  @override
  Iterable<String> get groups => onGettingProperties((lib) sync* {
    final SuperuserPluginWindowsBindings binding =
        SuperuserPluginWindowsBindings(lib);

    late int errCode;

    Pointer<DWORD> gpLengthPtr = ffi.calloc<DWORD>();
    int gpLength = 0;

    try {
      errCode = binding.count_associated_groups_length(gpLengthPtr);

      if (errCode != 0) {
        throw SuperuserProcessError(
          errCode,
          "Unable to obtain group informations.",
        );
      }

      gpLength = gpLengthPtr.value;
    } finally {
      ffi.calloc.free(gpLengthPtr);
    }

    Pointer<Pointer<WChar>> groupNamesPtr = ffi.calloc(gpLength);
    for (int gpIdx = 0; gpIdx < gpLength; gpIdx++) {
      groupNamesPtr[gpIdx] = ffi.calloc(MAX_USERNAME_CHAR);
    }

    Pointer<Pointer<Pointer<WChar>>> groupsPtr = ffi.calloc()
      ..value = groupNamesPtr;

    errCode = 0;
    int current = 0;

    try {
      errCode = binding.get_associated_groups(groupsPtr);

      if (errCode != 0) {
        throw SuperuserProcessError(
          errCode,
          "Unable to obtain group informations.",
        );
      }

      for (; current < gpLength; current++) {
        Pointer<ffi.Utf16> groupName = groupNamesPtr[current].cast<ffi.Utf16>();

        yield groupName.toDartString();

        ffi.calloc.free(groupNamesPtr[current]);
      }
    } finally {
      for (; current < gpLength; current++) {
        ffi.calloc.free(groupNamesPtr[current]);
      }
      ffi.calloc.free(groupNamesPtr);
      ffi.calloc.free(groupsPtr);
    }
  });
}
