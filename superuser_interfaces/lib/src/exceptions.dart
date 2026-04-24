import 'dart:io';

/// Indicate any errors encountered when fetching properties
/// in [SuperuserInterface].
class SuperuserProcessError extends Error implements OSError {
  /// Error code returned from native library.
  @override
  final int errorCode;

  /// Message to explain [errorCode].
  @override
  final String message;

  /// Name of a function, which yield error code such that
  /// causing this error thrown.
  final String errReturnedFuncName;

  /// Create [SuperuserProcessError] with given [errorCode].
  ///
  /// Optionally, provide a [message] for further explaination
  /// of error.
  SuperuserProcessError({
    required this.errorCode,
    required this.errReturnedFuncName,
    this.message =
        "Result from native process has been returned with error code.",
  }) : assert(errReturnedFuncName.trim().isNotEmpty);

  @override
  String toString() {
    StringBuffer buf = StringBuffer();

    buf
      ..write("SuperuserProcessError: ")
      ..writeln(message)
      ..write("\tFunction name in native code: ")
      ..writeln(errReturnedFuncName)
      ..write("\tError code: ")
      ..writeln(errorCode);

    return buf.toString();
  }
}
