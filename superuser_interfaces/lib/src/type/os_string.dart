import 'dart:io' show Platform;

import 'package:meta/meta.dart';

/// A [String] wrapper class for different comparison methods applied
/// in operating system when handing case of characters.
/// 
/// Since it only affect comparison related methods and operators, returned
/// value of [toString] will be exact same when it applied in constructors.
abstract final class OSString implements Comparable<OSString> {
  final String _value;

  const OSString._(this._value);

  /// Attach [value] into [OSString] with case sensitivity consideration of
  /// comparing two [OSString] based on operating system preference.
  /// 
  /// It returns uncased [OSString] if running in Windows or cased otherwise.
  factory OSString(String value) =>
      Platform.isWindows ? _OSUncasedString(value) : _OSCasedString(value);

  /// Create uncased comparison of [OSString] no matter which operating
  /// system is used.
  /// 
  /// It only available during test only.
  @visibleForTesting
  const factory OSString.uncased(String value) = _OSUncasedString;

  /// Create cased comparison of [OSString] no matter which operating
  /// system is used.
  /// 
  /// It only available during test only.
  @visibleForTesting
  const factory OSString.cased(String value) = _OSCasedString;

  @mustBeOverridden
  @override
  int get hashCode;

  @mustBeOverridden
  @override
  bool operator ==(Object other);

  @override
  String toString() {
    return _value;
  }
}

final class _OSUncasedString extends OSString {
  const _OSUncasedString(String value) : super._(value);

  @override
  bool operator ==(Object other) {
    if (other is OSString) {
      return _value.toUpperCase() == other._value.toUpperCase();
    }

    return false;
  }

  @override
  int compareTo(OSString other) {
    return _value.toUpperCase().compareTo(other._value.toUpperCase());
  }

  @override
  int get hashCode => _value.toUpperCase().hashCode;
}

final class _OSCasedString extends OSString {
  const _OSCasedString(String value) : super._(value);

  @override
  bool operator ==(Object other) {
    if (other is OSString) {
      return _value == other._value;
    }

    return false;
  }

  @override
  int compareTo(OSString other) {
    return _value.compareTo(other._value);
  }

  @override
  int get hashCode => _value.hashCode;
}
