import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart' as ffi;
import 'package:superuser_interfaces/superuser_interfaces.dart';

import 'superuser_plugin_unix_bindings_generated.dart';

const String _libName = 'superuser_plugin_unix';

/// The dynamic library in which the symbols for [SuperuserPluginUnixBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }

  if (Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }

  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final SuperuserPluginUnixBindings _bindings =
    SuperuserPluginUnixBindings(_dylib);

/// Define [SuperuserInterface] under UNIX environment.
///
/// Remark: [isActivated] is identical with [isSuperuser]
/// since `root` is a definition of superuser.
final class UnixSuperuser implements SuperuserInterface {
  UnixSuperuser() : assert(Platform.isMacOS || Platform.isLinux);

  @override
  bool get isActivated => isSuperuser;

  @override
  bool get isSuperuser => _bindings.is_root();

  @override
  String get whoAmI => _bindings.get_uname().cast<ffi.Utf8>().toDartString();
}
