import 'dart:io';

import 'package:meta/meta.dart';
import 'package:superuser_interfaces/superuser_interfaces.dart';
import 'package:superuser_plugin_unix/superuser_plugin_unix.dart';
import 'package:superuser_plugin_windows/superuser_plugin_windows.dart';

SuperuserInterface? _instance;

/// Retrive current instance of [SuperuserInterface].
///
/// If no instance was created before, it call
/// [bindInstance] automatically that assign
/// platform implemented [SuperuserInterface]
/// as current instance.
@internal
SuperuserInterface get instance {
  if (_instance == null) {
    SuperuserInstance.bindInstance(null);
  }

  return _instance!;
}

/// Manage instance of [SuperuserInterface] when accessing superuser
/// properties.
abstract final class SuperuserInstance {
  const SuperuserInstance._();

  /// Attach specified [suInterface] as data source of superuser
  /// property.
  ///
  /// If [suInterface] is `null`, it binds platform specified
  /// [SuperuserInterface] automatically if the platform is either
  /// Windows, macOS or Linux.
  ///
  /// It is possible (but rarely) to attach customized [SuperuserPlatform]
  /// if necessary.
  ///
  /// When [suInterface] is [SuperuserPlatform] (i.e [WindowsSuperuser]
  /// or [UnixSuperuser]), it cannot be constructed when testing as well
  /// as comply it's target platform that [UnsupportedError] will be thrown
  /// if violated. [MockSuperuser] can only be assigned when running in debug
  /// mode or during test that [UnsupportedError] also will be thrown if unsatified.
  /// In another word, only running program in debug mode can freely attach whatever
  /// [SuperuserInterface] implementation is used.
  static void bindInstance(SuperuserInterface? suInterface) {
    if (suInterface != null) {
      _instance = suInterface;
      return;
    }

    // Denote null interface as uses default implementation.
    if (Platform.isWindows) {
      _instance = WindowsSuperuser();
    } else if (Platform.isMacOS || Platform.isLinux) {
      _instance = UnixSuperuser();
    } else {
      throw UnimplementedError(
        "No default implementation available for this platform.",
      );
    }
  }

  /// Flush existed [SuperuserInterface] instance.
  @Deprecated(
    "This features is no longer required for Dart hook implementation.",
  )
  static void flushInstance() {
    if (_instance != null) {
      _instance = null;
    }
  }
}
