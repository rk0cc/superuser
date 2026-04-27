// ignore_for_file: hash_and_equals

import 'dart:collection';
import 'dart:io';

import 'package:meta/meta.dart';

/// Replicated [String] with modified matching mechnism applied
/// depended on which OS is used. [OSString] will print unmodified
/// string from input when calling [toString].
abstract final class OSString {
  /// Enable matching [String]s in captial letter.
  // ignore: constant_identifier_names
  static const int MATCH_CAPITAL = 0x2;

  /// Enable matching [String]s in small letter.
  // ignore: constant_identifier_names
  static const int MATCH_SMALL = 0x1;

  /// Apply matching staregy depending default behaviour
  /// of the OS.
  // ignore: constant_identifier_names
  static const int DEFAULT_MATCH = 0x0;

  final String _str;

  const OSString._(this._str);

  /// Get a default [String] matching behaviour depends on which
  /// OS is used or specify [flag] to override [String] matching
  /// staregy.
  /// 
  /// Value of [flag] is assigned by bitwise operation with
  /// [MATCH_CAPITAL] and [MATCH_SMALL] to enable matching staregy
  /// in capital and small letter case. Therefore, if case sensitive
  /// detection is preferred, the [flag] should be configured as
  /// `MATCH_CAPITAL | MATCH_SMALL`.
  ///
  /// If the [flag] assigned as [DEFAULT_MATCH], it returns
  /// [OSString.allCapital] for Windows platform and
  /// [OSString.caseSensitive] otherwise.
  factory OSString(String str, [int flag = DEFAULT_MATCH]) {
    int mode = flag & 0x3;

    if (mode == DEFAULT_MATCH) {
      mode |= MATCH_CAPITAL | (Platform.isWindows ? 0 : MATCH_SMALL);
    }

    return switch (mode) {
      0x3 => OSString.caseSensitive,
      0x2 => OSString.allCapital,
      0x1 => OSString.allSmall,
      _ => throw ArgumentError.value(
        flag,
        "flag",
        "Undefined matching flag combinations",
      ),
    }(str);
  }

  /// Using bitwise operation of enumerated [flag] to concrete [OSString].
  ///
  /// Flag value is a combination in 2-bit integer with enumerated
  /// constants [MATCH_CAPITAL], [MATCH_SMALL] and [DEFAULT_MATCH]
  /// to determine [OSString] matching staregy. For constructing
  /// [OSStringsSet.caseSensitive], use `MATCH_CAPTICAL | MATCH_SMALL`

  /// A [String] is going to compare with case sensivity, which exactly behave the same
  /// outcome when using [String.==] for matching.
  const factory OSString.caseSensitive(String str) = _CaseSensitiveOSString;

  /// A [String] is going to compare in all captical letter.
  const factory OSString.allCapital(String str) = _AllCapitalOSString;

  /// A [String] is going to compare in all small letter.
  const factory OSString.allSmall(String str) = _AllSmallOSString;

  String _convertStrNotation(String str);

  /// Determine the given [String] is matched by applying
  /// comparison staregy from [OSString].
  ///
  /// ```dart
  /// OSString foo = OSString.allCapital("Sample Text");
  /// print(foo <= "Sample Text"); // true
  /// print(foo <= "SAMPLE TEXT"); // true
  ///
  /// OSString bar = OSString.caseSensitive("Sample Text");
  /// print(bar <= "Sample Text"); // true
  /// print(bar <= "SAMPLE TEXT"); // false
  /// ```
  bool operator <=(String str) {
    return toCaseAppliedString() == _convertStrNotation(str);
  }

  /// Determine the given [OSString] has identical detection method as well as
  /// matched string representation.
  ///
  /// This operator aims to design for handling data collection in Dart mainly
  /// (i.e.: [Map] and [Set]). For finding matched [String] in literal, uses [<=] operator
  /// instead.
  @mustBeOverridden
  @override
  bool operator ==(Object other);

  @override
  int get hashCode => _convertStrNotation(_str).hashCode;

  /// Represent the applied [String] from the constructors.
  @override
  String toString() {
    return _str;
  }

  /// Return a converted [String] based on case sensivity rules
  /// were used when matching.
  @nonVirtual
  String toCaseAppliedString() {
    return _convertStrNotation(_str);
  }
}

final class _AllCapitalOSString extends OSString {
  const _AllCapitalOSString(super.str) : super._();

  @override
  bool operator ==(Object other) {
    if (other is _AllCapitalOSString) {
      return toCaseAppliedString() == other.toCaseAppliedString();
    }

    return false;
  }

  @override
  String _convertStrNotation(String str) {
    return str.toUpperCase();
  }
}

final class _AllSmallOSString extends OSString {
  const _AllSmallOSString(super.str) : super._();

  @override
  bool operator ==(Object other) {
    if (other is _AllSmallOSString) {
      return toCaseAppliedString() == _convertStrNotation(other._str);
    }

    return false;
  }

  @override
  String _convertStrNotation(String str) {
    return str.toLowerCase();
  }
}

final class _CaseSensitiveOSString extends OSString {
  const _CaseSensitiveOSString(super.str) : super._();

  @override
  bool operator ==(Object other) {
    if (other is _CaseSensitiveOSString) {
      return toCaseAppliedString() == _convertStrNotation(other._str);
    }

    return false;
  }

  @override
  String _convertStrNotation(String str) {
    return str;
  }
}

/// A collection of [OSString] with every elements comply matching
/// staregy when the first [OSString] inserted.
///
/// This set not only comply single object occurence of [Set], but
/// also mandated to unify [String] matching method except the first
/// added [OSString] element.
///
/// ```dart
/// final strs = OSStringsSet.of(<OSString>[
///   OSString.allCapital("foo"), // Retained
///   OSString.caseSensitive("FOO"), // Ignored
///   OSString.allCapital("bar"), // Retained
///   OSString.caseSensitive("baz") // Ignored
/// ]);
/// ```
abstract final class OSStringsSet extends SetBase<OSString> {
  const OSStringsSet._();

  /// Create empty set of [OSString].
  factory OSStringsSet() = _OSStringsSet;

  /// Create a [Set] and then immediate [addAll] provided [elements].
  factory OSStringsSet.of(Iterable<OSString> elements) =>
      OSStringsSet()..addAll(elements);

  /// Create an unmodifiable [OSStringsSet].
  factory OSStringsSet.unmodifiable(Iterable<OSString> elements) =
      _UnmodifiableOSStringsSet;

  /// Instantly create a [OSStringsSet] with [String] and preferred
  /// [flag] applied from [OSString.matchingFlag].
  factory OSStringsSet.fromStrings(
    Iterable<String> strs, [
    int flag = OSString.DEFAULT_MATCH,
  ]) => OSStringsSet.of(strs.map((str) => OSString(str, flag)));

  @override
  bool add(OSString value);

  @override
  void addAll(Iterable<OSString> elements);

  @override
  bool contains(Object? element);

  @override
  OSString? lookup(Object? element);

  @override
  bool remove(Object? value);
}

final class _OSStringsSet extends OSStringsSet {
  final LinkedHashSet<OSString> _strs = LinkedHashSet(
    equals: (p0, p1) => p0 == p1,
    hashCode: (p0) => Object.hash(p0, p0.runtimeType),
  );

  _OSStringsSet() : super._();

  @override
  bool add(OSString value) {
    if (_strs.isNotEmpty && _strs.first.runtimeType != value.runtimeType) {
      return false;
    }

    return _strs.add(value);
  }

  @override
  void addAll(Iterable<OSString> elements) {
    Type acceptedType = (_strs.isNotEmpty ? _strs : elements).first.runtimeType;

    _strs.addAll(elements.where((str) => str.runtimeType == acceptedType));
  }

  @override
  void clear() {
    _strs.clear();
  }

  @override
  bool contains(Object? element) {
    return lookup(element) != null;
  }

  @override
  Iterator<OSString> get iterator => _strs.iterator;

  @override
  int get length => _strs.length;

  @override
  OSString? lookup(Object? element) {
    if (element is OSString) {
      return _strs.lookup(element);
    }

    if (element is String) {
      return _strs.singleWhere((str) => str <= element);
    }

    return null;
  }

  @override
  bool remove(Object? value) {
    return _strs.remove(lookup(value));
  }

  @override
  Set<OSString> toSet() {
    return _strs.toSet();
  }
}

final class _UnmodifiableOSStringsSet extends UnmodifiableSetView<OSString>
    implements OSStringsSet {
  _UnmodifiableOSStringsSet(Iterable<OSString> source)
    : super(OSStringsSet.of(source));
}
