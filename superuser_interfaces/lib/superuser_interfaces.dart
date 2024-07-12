library interfaces;

/// Shared interface for evaluating superuser status when
/// executing Flutter program.
abstract interface class SuperuserInterface {
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

  /// Create mocked properties of [SuperuserInterface] to emulate
  /// superuser status.
  /// 
  /// It is forbidden to enable [isActivated] without [isSuperuser]. 
  MockSuperuser(
      {this.isSuperuser = false,
      this.isActivated = false,
      this.whoAmI = ""})
      : assert(() {
          if (!isSuperuser) {
            return !isActivated;
          }

          return true;
        }(), "Non-superuser cannot be activated.");
}
