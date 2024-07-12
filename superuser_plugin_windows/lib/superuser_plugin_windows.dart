import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart' as ffi;
import 'package:superuser_interfaces/superuser_interfaces.dart'
    show SuperuserInterface;

import 'superuser_plugin_windows_bindings_generated.dart';

const String _libName = 'superuser_plugin_windows';

/// The dynamic library in which the symbols for [SuperuserPluginWindowsBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }

  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final SuperuserPluginWindowsBindings _bindings =
    SuperuserPluginWindowsBindings(_dylib);

/// Construct [SuperuserInterface] based on Windows API.
final class WindowsSuperuser implements SuperuserInterface {
  WindowsSuperuser() : assert(Platform.isWindows);

  /* TODO: Make Win32's 'BOOL' map to 'bool' */

  @override
  bool get isActivated => _bindings.is_elevated() != 0;

  @override
  bool get isSuperuser => _bindings.is_admin_user() != 0;

  @override
  String get whoAmI =>
      _bindings.get_current_username().cast<ffi.Utf16>().toDartString();
}
