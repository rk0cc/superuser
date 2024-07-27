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

  /// Create [SuperuserProcessError] with given [errorCode].
  ///
  /// Optionally, provide a [message] for further explaination
  /// of error.
  SuperuserProcessError(this.errorCode, [this.message = ""]);

  @override
  String toString() {
    StringBuffer buf = StringBuffer();

    buf.write("SuperuserProcessError: ");

    if (message.isNotEmpty) {
      buf
        ..write(message)
        ..write(" (error code: $errorCode)");
    } else {
      buf.write("process return with error code $errorCode");
    }

    return buf.toString();
  }
}
