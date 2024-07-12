library superuser;

import 'src/instance.dart';

abstract final class Superuser {
  const Superuser._();

  static bool get isSuperuser => SuperuserInstance.instance.isSuperuser;

  static bool get isActivated => SuperuserInstance.instance.isActivated;

  static String get whoAmI => SuperuserInstance.instance.whoAmI;
}
