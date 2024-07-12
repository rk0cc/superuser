import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart' as ffi;
import 'package:superuser_interfaces/superuser_interfaces.dart'
    show SuperuserInterface;

import 'superuser_plugin_windows_bindings_generated.dart';

const String _libName = 'superuser_plugin_windows';

/// Construct [SuperuserInterface] based on Windows API.
final class WindowsSuperuser implements SuperuserInterface {
  static WindowsSuperuser? _instance;

  late final SuperuserPluginWindowsBindings _bindings;

  WindowsSuperuser._() {
    _bindings = SuperuserPluginWindowsBindings(() {
      if (Platform.isWindows) {
        return DynamicLibrary.open('$_libName.dll');
      }

      throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
    }());
  }

  factory WindowsSuperuser() {
    _instance ??= WindowsSuperuser._();

    return _instance!;
  }

  /* TODO: Make Win32's 'BOOL' map to 'bool' */

  @override
  bool get isActivated => _bindings.is_elevated() != 0;

  @override
  bool get isSuperuser => _bindings.is_admin_user() != 0;

  @override
  String get whoAmI =>
      _bindings.get_current_username().cast<ffi.Utf16>().toDartString();
}
