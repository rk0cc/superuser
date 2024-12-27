import 'dart:io';

import 'package:meta/meta.dart';

/// A [String] with matched case sensitivity for comparison regarding
/// which operating system is used.
/// 
/// The alternation of [String] value would be made only when using 
/// [compareTo], [hashCode] and [==] internally. And [toString] will
/// returns the value when applied.
sealed class IdentifierName implements Comparable<IdentifierName> {
  final String _value;

  const IdentifierName._(String value) : _value = value;

  /// Assign [value] into [IdentifierName] by respecting comparison stragety
  /// in different operating system.
  /// 
  /// It returns [WindowsIdentifierName] if [Platform.isWindows] is `true`,
  /// which compare [String] without considering cases for each characters.
  /// Otherwise, [UnixIdentifierName] will be returned instead.
  factory IdentifierName(String value) => Platform.isWindows
      ? WindowsIdentifierName(value)
      : UnixIdentifierName(value);

  @override
  int compareTo(IdentifierName other);

  @mustBeOverridden
  @override
  int get hashCode;

  @override
  String toString() {
    return _value;
  }

  @mustBeOverridden
  @override
  bool operator ==(Object other);
}

/// An [IdentifierName] with comparsion rule applied in Windows.
/// 
/// The comparison result will be based on [String.toUpperCase]
/// between itself and other [IdentifierName] value.
final class WindowsIdentifierName extends IdentifierName {
  const WindowsIdentifierName(super.value) : super._();

  @override
  int compareTo(IdentifierName other) {
    return _value.toUpperCase().compareTo(other._value.toUpperCase());
  }

  @override
  int get hashCode => _value.toUpperCase().hashCode;

  @override
  bool operator ==(Object other) {
    if (other is IdentifierName) {
      return _value.toUpperCase() == other._value.toUpperCase();
    }

    return false;
  }
}

final class UnixIdentifierName extends IdentifierName {
  const UnixIdentifierName(super.value) : super._();

  @override
  int compareTo(IdentifierName other) {
    return _value.compareTo(other._value);
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is IdentifierName) {
      return _value == other._value;
    }

    return false;
  }
}
