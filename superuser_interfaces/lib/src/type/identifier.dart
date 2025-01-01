import 'package:meta/meta.dart';

/// A name applies with different [compareTo] condition based on operating
/// system preference.
/// 
/// This class serves as [String] wrapper with customized [Compareable]
/// implementations that it should only modifies comparison methods or operators
/// without altering applied value itself. Therefore, the returned value of
/// [toString] must be identical when it applied in constructor.
abstract final class OSName<T extends OSName<T>> implements Comparable<T> {
  final String _value;

  const OSName._(this._value);

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

/// An [OSName] without considering case sensivity of given value.
/// 
/// It refers [String.toUpperCase] to compare differences.
final class WindowsName extends OSName<WindowsName> {
  /// Assign given [value] and using [String.toUpperCase] as
  /// to compare with other [WindowsName].
  const WindowsName(String value) : super._(value);

  String get _compareValue => _value.toUpperCase();

  @override
  bool operator ==(Object other) {
    if (other is WindowsName) {
      return _compareValue == other._compareValue;
    }

    return false;
  }

  @override
  int compareTo(WindowsName other) {
    return _compareValue.compareTo(other._compareValue);
  }

  @override
  int get hashCode => _compareValue.hashCode;
}

/// An [OSName] with considering case sensivity of value.
/// 
/// In other words, it takes assigned value to compare without
/// any alternation.
final class UnixName extends OSName<UnixName> {
  /// Assign [value] as [OSName] in UNIX system.
  const UnixName(String value) : super._(value);

  @override
  bool operator ==(Object other) {
    if (other is UnixName) {
      return _value == other._value;
    }

    return false;
  }

  @override
  int compareTo(UnixName other) {
    return _value.compareTo(other._value);
  }

  @override
  int get hashCode => _value.hashCode;
}

/// A general interface to extract information of identity from
/// operating system.
abstract interface class OSIdentifier<T> {
  /// A unique value uses for representing this interface.
  T get id;

  /// Name of [OSIdentifier] with comparison method applied in
  /// operating system.
  OSName get name;
}
