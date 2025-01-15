import 'dart:collection';

import 'package:meta/meta.dart';

abstract final class Identifier<I extends Comparable,
    T extends Identifier<I, T>> implements Comparable<T> {
  final I id;
  final String name;

  const Identifier(this.id, this.name);

  @override
  int compareTo(T other) {
    return id.compareTo(other.id);
  }

  int compareToName(T other);

  @override
  String toString() {
    return "($name: $id)";
  }
}

abstract base class Group<I extends Comparable, T extends Group<I, T>>
    extends Identifier<I, T> {
  const Group(super.id, super.name);

  
}

abstract base class User<I extends Comparable, T extends User<I, T>>
    extends Identifier<I, T> {
  const User(super.id, super.name);
}

abstract base class GroupSet<I extends Comparable, E extends Group<I, E>>
    implements Set<E> {
  final LinkedHashSet<E> _idSet;

  GroupSet(
    Iterable<E> groups, {
    int Function(E)? hashCode,
  }) : _idSet = LinkedHashSet(
            equals: (a, b) => a.compareTo(b) == 0 || a.compareToName(b) == 0,
            hashCode: hashCode)
          ..addAll([...groups]..sort());

  @override
  bool add(E value) {
    throw UnsupportedError("add");
  }

  @override
  void addAll(Iterable<E> elements) {
    throw UnsupportedError("addAll");
  }

  @override
  bool any(bool Function(E element) test) {
    return _idSet.any(test);
  }

  @override
  Set<R> cast<R>() {
    return _idSet.cast<R>();
  }

  @override
  void clear() {
    throw UnsupportedError("clear");
  }

  @override
  bool contains(Object? value) {
    return _idSet.contains(value);
  }

  bool containsId(I id);

  bool containsName(String name);

  @override
  bool containsAll(Iterable<Object?> other) {
    return _idSet.containsAll(other);
  }

  @override
  Set<E> difference(Set<Object?> other) {
    return _idSet.difference(other);
  }

  @override
  E elementAt(int index) {
    return _idSet.elementAt(index);
  }

  @override
  bool every(bool Function(E element) test) {
    return _idSet.every(test);
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) {
    return _idSet.expand(toElements);
  }

  @override
  E get first => _idSet.first;

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) {
    return _idSet.firstWhere(test);
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    return _idSet.fold(initialValue, combine);
  }

  @override
  Iterable<E> followedBy(Iterable<E> other) {
    return _idSet.followedBy(other);
  }

  @override
  void forEach(void Function(E element) action) {
    _idSet.forEach(action);
  }

  @override
  Set<E> intersection(Set<Object?> other) {
    return _idSet.intersection(other);
  }

  @override
  bool get isEmpty => _idSet.isEmpty;

  @override
  bool get isNotEmpty => _idSet.isNotEmpty;

  @override
  Iterator<E> get iterator => _idSet.iterator;

  @override
  String join([String separator = ""]) {
    return _idSet.join(separator);
  }

  @override
  E get last => _idSet.last;

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) {
    return _idSet.lastWhere(test);
  }

  @override
  int get length => _idSet.length;

  @override
  E? lookup(Object? object) {
    return _idSet.lookup(object);
  }

  @override
  Iterable<T> map<T>(T Function(E e) toElement) {
    return _idSet.map(toElement);
  }

  @override
  E reduce(E Function(E value, E element) combine) {
    return _idSet.reduce(combine);
  }

  @override
  bool remove(Object? value) {
    throw UnsupportedError("remove");
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    throw UnsupportedError("removeAll");
  }

  @override
  void removeWhere(bool Function(E element) test) {
    throw UnsupportedError("removeWhere");
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    throw UnsupportedError("retainAll");
  }

  @override
  void retainWhere(bool Function(E element) test) {
    throw UnsupportedError("retainWhere");
  }

  @override
  E get single => _idSet.single;

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) {
    return _idSet.singleWhere(test);
  }

  @override
  Iterable<E> skip(int count) {
    return _idSet.skip(count);
  }

  @override
  Iterable<E> skipWhile(bool Function(E value) test) {
    return _idSet.skipWhile(test);
  }

  void sort([Comparator<E>? compare]) {
    List<E> sortedGp = [..._idSet]..sort(compare);

    _idSet
      ..clear()
      ..addAll(sortedGp);
  }

  @override
  Iterable<E> take(int count) {
    return _idSet.take(count);
  }

  @override
  Iterable<E> takeWhile(bool Function(E value) test) {
    return _idSet.takeWhile(test);
  }

  @override
  List<E> toList({bool growable = true}) {
    return _idSet.toList(growable: growable);
  }

  @override
  Set<E> toSet() {
    return _idSet.toSet();
  }

  @override
  Set<E> union(Set<E> other) {
    return _idSet.union(other);
  }

  @override
  Iterable<E> where(bool Function(E element) test) {
    return _idSet.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return _idSet.whereType<T>();
  }

  @override
  String toString() {
    return "{${join(", ")}}";
  }
}
