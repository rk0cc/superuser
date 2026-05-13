import 'execution.dart';
import 'os_string.dart';

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
  OSString get whoAmI;

  /// Obtains all groups name that this user is associated.
  OSStringsSet get groups;
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
    if (isTesting) {
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
/// ["Run as administrator"](https://learn.microsoft.com/en-us/troubleshoot/windows-server/shell-experience/use-run-as-start-app-admin)
/// for Windows, [`sudo`](https://man7.org/linux/man-pages/man8/sudo.8.html) for most UNIX system
/// or prompting [polkit](https://www.freedesktop.org/software/polkit/docs/latest/polkit.8.html)
/// for common desktop environments of Linux distros.
final class MockSuperuser implements SuperuserInterface {
  @override
  final bool isSuperuser;

  @override
  final bool isActivated;

  @override
  final OSString whoAmI;

  @override
  final OSStringsSet groups;

  /// Create mocked properties of [SuperuserInterface] to emulate
  /// superuser status.
  ///
  /// [whoAmI] and [groups] will be applied the same [OSString]
  /// matching method by configuring [matchingFlag], which has been
  /// instructed in [OSString.new] already.
  MockSuperuser({
    this.isSuperuser = false,
    this.isActivated = false,
    String whoAmI = "",
    Set<String> groups = const {},
    int matchingFlag = OSString.DEFAULT_MATCH,
  }) : whoAmI = OSString(whoAmI, matchingFlag),
       groups = OSStringsSet.fromStrings(groups, matchingFlag) {
    if (isProduction) {
      throw UnsupportedError("Do not uses mock instance in production state.");
    }
  }
}
