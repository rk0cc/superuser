import 'dart:io';

import 'package:meta/meta.dart';

@internal
bool get kUnderDevelop => Platform.environment.containsKey("FLUTTER_TEST");
