// ignore_for_file: avoid_print

import 'package:superuser/superuser.dart';

void main() {
  print("Superuser member: ${Superuser.isSuperuser}");
  print("Running as superuser: ${Superuser.isActivated}");
}
