import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:superuser_interfaces/superuser_interfaces.dart';
import 'package:superuser_plugin_unix/superuser_plugin_unix.dart';
import 'package:superuser_plugin_windows/superuser_plugin_windows.dart';

import 'exception.dart';
import 'utils.dart';

SuperuserInterface? _instance;

/// Retrive current instance of [SuperuserInterface].
///
/// If no instance was created before, it call
/// [bindInstance] automatically that assign
/// platform implemented [SuperuserInterface]
/// as current instance.
@internal
SuperuserInterface get instance {
  if (_instance == null ||
      _instance is SuperuserPlatform &&
          (_instance as SuperuserPlatform).isClosed) {
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
  /// [SuperuserInterface] automatically.
  ///
  /// When this invoked in neither Windows, macOS or Linux platform,
  /// it throws [UnsupportedError].
  ///
  /// If [suInterface] is a member of [SuperuserPlatform],
  /// the provided interface should not be closed. Otherwise,
  /// it throws [ArgumentError].
  ///
  /// [suInterface] can only accept [MockSuperuser] if [kDebugMode]
  /// or it performs widget testing. Using mock interface in
  /// [kReleaseMode] or [kProfileMode] causes [IllegalInstanceError]
  /// throw.
  static void bindInstance(SuperuserInterface? suInterface) {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      throw UnsupportedError("Unknown platform");
    }

    if (!kUnderDevelop && suInterface is MockSuperuser) {
      throw IllegalInstanceError(
          "Mock instance cannot be used in release mode.");
    }

    flushInstance();

    late SuperuserInterface newInst;

    if (suInterface == null) {
      // Denote null interface as uses default implementation.
      if (Platform.isWindows) {
        newInst = WindowsSuperuser();
      } else if (Platform.isMacOS || Platform.isLinux) {
        newInst = UnixSuperuser();
      }
    } else {
      if (suInterface is SuperuserPlatform && suInterface.isClosed) {
        throw ArgumentError(
            "The provided interface should not be closed already.",
            "suInterface");
      }

      newInst = suInterface;
    }

    _instance = newInst;
  }

  /// Flush existed [SuperuserInterface] instance.
  static void flushInstance() {
    if (_instance != null) {
      if (_instance is SuperuserPlatform) {
        (_instance as SuperuserPlatform).close();
      }

      _instance = null;
    }
  }
}
