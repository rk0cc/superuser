import 'dart:io';

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

  /// Obtains all groups name that this user is associated.
  Iterable<String> get groups;
}

/// Platform specified [SuperuserInterface] to retrive properties from
/// plugins.
///
/// This cannot be used in tesing due to unpredictable expectation
/// of properties. Therefore, [MockSuperuser] must be used
/// to ensure all properties are controllable that all test
/// results should be predictable.
abstract base class SuperuserPlatform implements SuperuserInterface {
  /// Create [SuperuserPlatform] for targeted platform.
  ///
  /// Usually, it should performs binding from plugin to ensure
  /// [SuperuserInterface]'s properties can be fetched.
  ///
  /// This cannot be used in testing environment and
  /// [UnsupportedError] throw if attempted to construst
  /// in testing.
  SuperuserPlatform() {
    if (Platform.environment.containsKey("FLUTTER_TEST") ||
        Platform.script.path.contains("dart_test")) {
      throw UnsupportedError(
        "Using real superuser result to run test is forbidden.",
      );
    }
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
  final Set<String> groups;

  /// Create mocked properties of [SuperuserInterface] to emulate
  /// superuser status.
  const MockSuperuser({
    this.isSuperuser = false,
    this.isActivated = false,
    this.whoAmI = "",
    this.groups = const <String>{},
  });
}
