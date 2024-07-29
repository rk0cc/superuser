import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

@internal
bool get kUnderDevelop =>
    kDebugMode || Platform.environment.containsKey("FLUTTER_TEST");
