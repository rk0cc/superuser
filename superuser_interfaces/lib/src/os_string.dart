// ignore_for_file: hash_and_equals

import 'package:meta/meta.dart';

abstract final class OSString {
  final String _str;

  const OSString._(this._str);

  const factory OSString(String str) = _CaseSensitiveOSString;

  const factory OSString.allCapital(String str) = _AllCapitalOSString;

  const factory OSString.allSmall(String str) = _AllSmallOSString;

  String _convertStrNotation(String str);

  bool operator >=(String str) {
    return _convertStrNotation(_str) == _convertStrNotation(str);
  }

  @mustBeOverridden
  @override
  bool operator ==(Object other);

  @override
  int get hashCode => _convertStrNotation(_str).hashCode;

  @override
  String toString() {
    return _str;
  }
}

final class _AllCapitalOSString extends OSString {
  const _AllCapitalOSString(super.str) : super._();

  @override
  bool operator ==(Object other) {
    if (other is _AllCapitalOSString) {
      return _convertStrNotation(_str) == _convertStrNotation(other._str);
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
      return _convertStrNotation(_str) == _convertStrNotation(other._str);
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
      return _convertStrNotation(_str) == _convertStrNotation(other._str);
    }

    return false;
  }

  @override
  String _convertStrNotation(String str) {
    return str;
  }
}
