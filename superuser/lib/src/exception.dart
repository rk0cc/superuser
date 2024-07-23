import 'package:superuser_interfaces/superuser_interfaces.dart';

/// Indicate the given [SuperuserInterface] is illegal to
/// uses.
final class IllegalInstanceError extends Error {
  /// Message of [IllegalInstanceError] to explain reason
  /// of causing this error throw.
  final String message;

  /// Construct new error with given message.
  IllegalInstanceError(this.message);

  @override
  String toString() {
    return "IllegalInstanceError: $message";
  }
}