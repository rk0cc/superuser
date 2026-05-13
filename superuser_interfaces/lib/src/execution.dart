import 'dart:io';

import 'package:meta/meta.dart';

@internal
final bool isTesting =
    Platform.environment.containsKey("FLUTTER_TEST") ||
    Platform.script.path.contains("dart_test");

@internal
final bool isProduction = [
  "profile",
  "product",
].map((mode) => "dart.vm.$mode").any(bool.fromEnvironment);
