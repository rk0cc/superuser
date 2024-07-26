import 'dart:ffi' show DynamicLibrary;
import 'dart:io';

import 'package:meta/meta.dart';

import 'user_group.dart';

/// Shared interface for evaluating superuser status when
/// executing Flutter program.
abstract final class SuperuserInterface {
  const SuperuserInterface._();

  /// Determine current user has superuser role.
  ///
  /// To determine Flutter program executed with
  /// superuser right, consider using [isActivated].
  bool get isSuperuser;

  /// Determine this program is executed with superuser right.
  ///
  /// This can be `true` only if [isSuperuser] `true` at the
  /// same time.
  bool get isActivated;

  /// Retrive name of user, who run this program.
  String get whoAmI;

  /// Obtains user as one of member of [Group]s.
  Set<Group> get groups;
}

/// Platform specified [SuperuserInterface] to retrive properties from
/// plugins.
///
/// This cannot be used in tesing due to unpredictable expectation
/// of properties. Therefore, [MockSuperuser] must be used
/// to ensure all properties are controllable that all test
/// results should be predictable.
abstract base class SuperuserPlatform implements SuperuserInterface {
  final DynamicLibrary _nativeLibrary;
  bool _closed = false;

  /// Create [SuperuserPlatform] for targeted platform.
  ///
  /// Usually, it should performs binding from plugin to ensure
  /// [SuperuserInterface]'s properties can be fetched.
  ///
  /// This cannot be used in testing environment and
  /// [UnsupportedError] throw if attempted to construst
  /// in testing.
  SuperuserPlatform(DynamicLibrary Function() nativeLibrary)
      : _nativeLibrary = nativeLibrary() {
    if (Platform.environment.containsKey("FLUTTER_TEST")) {
      throw UnsupportedError(
          "Using real superuser result to run test is forbidden.");
    }
  }

  /// Middleman of retrive properties from [handler] and prevent
  /// it when [isClosed], which throw [StateError] instead.
  @protected
  @nonVirtual
  T onGettingProperties<T>(T Function(DynamicLibrary) handler) {
    if (isClosed) {
      throw StateError("This instance has been closed already.");
    }

    return handler(_nativeLibrary);
  }

  /// Determine it called [close] already that it no longer
  /// returns properties from native library.
  @nonVirtual
  bool get isClosed => _closed;

  /// Terminate and release resources of native libary.
  ///
  /// All properties in [SuperuserInterface] will no longer
  /// be fetched and throws [StateError] if try to retrive
  /// properties after this method called.
  @nonVirtual
  void close() {
    _nativeLibrary.close();
    _closed = true;
  }
}

/// Replicate behaviour of [SuperuserInterface], which
/// fulfilled requirements of testing.
///
/// It is ideal for widget testing that it can simulate
/// superuser status without
/// [Run as administrator](https://learn.microsoft.com/en-us/troubleshoot/windows-server/shell-experience/use-run-as-start-app-admin)
/// or [`sudo` command](https://man7.org/linux/man-pages/man8/sudo.8.html).
final class MockSuperuser implements SuperuserInterface {
  @override
  final bool isSuperuser;

  @override
  final bool isActivated;

  @override
  final String whoAmI;

  @override
  final Set<Group> groups;

  /// Create mocked properties of [SuperuserInterface] to emulate
  /// superuser status.
  const MockSuperuser(
      {this.isSuperuser = false,
      this.isActivated = false,
      this.whoAmI = "",
      this.groups = const <Group>{}});
}
