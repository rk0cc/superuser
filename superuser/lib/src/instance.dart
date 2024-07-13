import 'dart:io';

import 'package:meta/meta.dart';
import 'package:superuser_interfaces/superuser_interfaces.dart';
import 'package:superuser_plugin_unix/superuser_plugin_unix.dart';
import 'package:superuser_plugin_windows/superuser_plugin_windows.dart';

/// Manage instance of [SuperuserInterface] when accessing superuser
/// properties.
@internal
abstract final class SuperuserInstance {
  static SuperuserInterface? _instance;

  const SuperuserInstance._();

  /// Retrive current instance of [SuperuserInterface].
  ///
  /// If no instance was created before, it call
  /// [bindInstance] automatically that assign
  /// platform implemented [SuperuserInterface]
  /// as current instance.
  static SuperuserInterface get instance {
    if (_instance == null) {
      bindInstance(null);
    }

    return _instance!;
  }
}

/// Attach specified [suInterface] as data source of superuser
/// property.
///
/// If [suInterface] is `null`, it binds platform specified
/// [SuperuserInterface] automatically.
/// 
/// When this invoked in neither Windows, macOS or Linux platform,
/// it throws [UnsupportedError].
void bindInstance(SuperuserInterface? suInterface) {
  if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
    throw UnsupportedError("Unknown platform");
  }

  late SuperuserInterface newInst;

  if (suInterface == null) {
    // Denote null interface as uses default implementation.
    if (Platform.isWindows) {
      newInst = WindowsSuperuser();
    } else if (Platform.isMacOS || Platform.isLinux) {
      newInst = UnixSuperuser();
    }
  } else {
    newInst = suInterface;
  }

  SuperuserInstance._instance = newInst;
}
