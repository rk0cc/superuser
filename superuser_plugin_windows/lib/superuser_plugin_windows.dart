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

          throw UnsupportedError(
              'Unknown platform: ${Platform.operatingSystem}');
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
                errCode, "Cannot determine superuser activation status.");
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
                errCode, "Unable to retrive user's superuser role.");
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

        Pointer<Pointer<Char>> resultPtr = ffi.calloc<Pointer<Char>>();

        try {
          int errResult = binding.get_current_username(resultPtr);

          if (errResult != 0) {
            throw SuperuserProcessError(
                errResult, "Unable to extract current username.");
          }

          Pointer<Char> result = resultPtr.value;

          try {
            Pointer<ffi.Utf8> ctx = result.cast<ffi.Utf8>();

            return ctx.toDartString();
          } finally {
            binding.flush(result.cast<Void>());
          }
        } finally {
          ffi.calloc.free(resultPtr);
        }
      });

  @override
  Iterable<String> get groups => onGettingProperties((lib) {
        final SuperuserPluginWindowsBindings binding =
            SuperuserPluginWindowsBindings(lib);

        Pointer<Pointer<Pointer<Char>>> gps =
            ffi.calloc<Pointer<Pointer<Char>>>();
        Pointer<DWORD> size = ffi.calloc<DWORD>();

        Iterable<Pointer<Char>> iteratedGps() sync* {
          Pointer<Pointer<Char>> gpArrPtr = gps.value;

          for (int i = 0; i < size.value; i++) {
            yield gpArrPtr[i];
          }

          binding.flush(gpArrPtr.cast<Void>());
        }

        try {
          int errCode = binding.get_associated_groups(gps, size);

          if (errCode != 0) {
            throw SuperuserProcessError(
                errCode, "Unable to extract group information.");
          }

          return iteratedGps().map((ptr) {
            try {
              Pointer<ffi.Utf8> utfStr = ptr.cast<ffi.Utf8>();

              return utfStr.toDartString();
            } finally {
              binding.flush(ptr.cast<Void>());
            }
          });
        } finally {
          <Pointer>[gps, size].forEach(ffi.calloc.free);
        }
      });
}
