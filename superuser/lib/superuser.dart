/// Fundamental library for fetching superuser status.
///
/// It only offers [Superuser] class to access superuser conditions
/// as well as username who run current Flutter program.
library superuser;

import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:superuser_interfaces/superuser_interfaces.dart'
    show MockSuperuser;

import 'src/instance.dart';
import 'src/exception.dart';

export 'package:superuser_interfaces/superuser_interfaces.dart'
    show SuperuserProcessError;

export 'src/exception.dart';

/// A wrapper class that extract status of superuser as well as username.
///
/// By default, [Superuser] will load instance for specific platform automatically.
/// If mock data is required, please attach [MockSuperuser] into [SuperuserInstance.bindInstance]
/// before calling any getters in [Superuser]. However, attaching mock instance
/// must be done only in [kDebugMode] or causing [IllegalInstanceError]
/// throw otherwise.
abstract final class Superuser {
  const Superuser._();

  /// Determine this program is executed by a user, who is superuser exactly or
  /// one of members in superuser group that it is possible to toggle [isActivated]
  /// (it can be executed with restricted permission that making [isActivated] retains
  /// false).
  ///
  /// For UNIX platform, it returns true if user who execute this program is `root`
  /// or a member of built-in group that can uses `sudo` command. (`admin` for macOS
  /// or `sudo` for majority of Linux systems).
  ///
  /// In Windows, it returns true if current user is a member of `Administrators`
  /// group in local machine. This detection does not consider Active Directory
  /// users.
  static bool get isSuperuser => instance.isSuperuser;

  /// Determine this program is running with superuser role that it can
  /// access and modify protected location programmatically.
  ///
  /// UNIX platforms (macOS and Linux) only consider executor is `root`,
  /// whatever how this program called.
  ///
  /// For Windows platform, it consider this process has been elevated
  /// or not, which should be positive if and only if user granted UAC
  /// prompt.
  static bool get isActivated => instance.isActivated;

  /// Obtain username who call current program.
  static String get whoAmI => instance.whoAmI;

  /// Obtain user's associated groups in local system.
  static Set<String> get groups =>
      UnmodifiableSetView(LinkedHashSet(equals: (a, b) {
        String cmpA = a, cmpB = b;

        if (Platform.isWindows) {
          cmpA = cmpA.toUpperCase();
          cmpB = cmpB.toUpperCase();
        }

        return cmpA == cmpB;
      }, hashCode: (str) {
        String hashStr = str;

        if (Platform.isWindows) {
          hashStr = hashStr.toUpperCase();
        }

        return hashStr.hashCode;
      })
        ..addAll(instance.groups));
}
