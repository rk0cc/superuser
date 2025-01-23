import 'dart:io';

/// Detailed information from [SuperuserProcessError] to indicate
/// the result returns with error in FFI.
final class ErrorDetail {
  /// Error code from FFI methods.
  final int code;

  /// Name of API method, which cause this error occured.
  final String apiMethodName;

  /// Name of getter of the [code].
  final String errGetterName;

  /// Create detailed error information from FFI.
  const ErrorDetail(this.code, this.apiMethodName, this.errGetterName);
}

/// Indicate any errors encountered when fetching properties
/// in [SuperuserInterface].
class SuperuserProcessError extends Error implements OSError {
  /// A structured information that containing how this error
  /// throw when executing FFI.
  final ErrorDetail detail;

  /// Message to explain based on [detail].
  @override
  final String message;

  /// Create [SuperuserProcessError] with given error [detail].
  ///
  /// Optionally, provide a [message] for further explaination
  /// of error.
  SuperuserProcessError(this.detail, [this.message = ""]);

  @override
  int get errorCode => detail.code;

  @override
  String toString() {
    StringBuffer buf = StringBuffer();

    buf.write("SuperuserProcessError: ");

    if (message.isNotEmpty) {
      buf
        ..write(message)
        ..writeln(" (error code: $errorCode)");
    } else {
      buf.writeln("process return with error code $errorCode");
    }

    buf
      ..writeln("Method name: ${detail.apiMethodName}")
      ..writeln("Error getter: ${detail.errGetterName}");

    return buf.toString();
  }
}
