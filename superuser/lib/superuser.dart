/// Fundamental library for fetching superuser status.
///
/// It only offers [Superuser] class to access superuser conditions
/// as well as username who run current Flutter program.
library superuser;

import 'package:superuser_interfaces/superuser_interfaces.dart'
    show MockSuperuser;

import 'src/instance.dart';

/// A wrapper class that extract status of superuser as well as username.
///
/// By default, [Superuser] will load instance for specific platform automatically.
/// If mock data is required, please attach [MockSuperuser] into [bindInstance]
/// before calling any getters in [Superuser].
abstract final class Superuser {
  const Superuser._();

  /// Determine this program is executed by a user, who is superuser exactly or
  /// one of members in superuser group.
  static bool get isSuperuser => instance.isSuperuser;

  /// Determine this program is running with superuser role.
  ///
  /// If this getter called in UNIX platforms (macOS or Linux),
  /// it is an alias getter of [isSuperuser] since `root` is one and only
  /// user can be represented as superuser.
  ///
  /// For Windows platform, it consider this process has been elevated
  /// or not.
  static bool get isActivated => instance.isActivated;

  /// Obtain username who call current program.
  static String get whoAmI => instance.whoAmI;
}
