import 'dart:io';

import 'package:superuser_interfaces/superuser_interfaces.dart';
import 'package:superuser_plugin_unix/superuser_plugin_unix.dart';
import 'package:superuser_plugin_windows/superuser_plugin_windows.dart';

abstract final class SuperuserInstance {
  static SuperuserInterface? _instance;

  const SuperuserInstance._();

  static SuperuserInterface get instance {
    if (_instance == null) {
      bindInstance(null);
    }

    return _instance!;
  }
}

void bindInstance(SuperuserInterface? suInterface) {
    late SuperuserInterface newInst;

    if (suInterface == null) {
      // Denote null interface as uses default implementation.
      if (Platform.isWindows) {
        newInst = WindowsSuperuser();
      } else if (Platform.isMacOS || Platform.isLinux) {
        newInst = UnixSuperuser();
      } else {
        throw UnsupportedError("Unknown platform");
      }
    } else {
      newInst = suInterface;
    }

    SuperuserInstance._instance = newInst;
  }
