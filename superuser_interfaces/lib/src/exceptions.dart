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

  /// Name of functions from FFI that it cause this error thrown.
  ///
  /// `entryPoint` refers to a FFI function, which called directly
  /// from Dart VM and `nativeAPI` refers to the name if native API
  /// function, which is a root cause of triggering this error.
  final ({String entryPoint, String nativeAPI}) functionName;

  /// Create [SuperuserProcessError] with given [errorCode].
  ///
  /// Optionally, provide a [message] for further explaination
  /// of error.
  SuperuserProcessError({
    required this.errorCode,
    required this.functionName,
    this.message =
        "Result from native process has been returned with error code.",
  }) : assert(
         [
           functionName.entryPoint,
           functionName.nativeAPI,
         ].every((funcName) => funcName.trim().isNotEmpty),
       );

  @override
  String toString() {
    StringBuffer buf = StringBuffer();

    buf
      ..write("SuperuserProcessError: ")
      ..writeln(message)
      ..write("\tFunction name in native code: ")
      ..writeln(functionName.nativeAPI)
      ..write("\tError code: ")
      ..writeln(errorCode);

    return buf.toString();
  }
}
