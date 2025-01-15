import 'dart:collection';

mixin Identifier<I extends Comparable, T extends Identifier<I, T>>
    implements Comparable<T> {
  I get id;
  String get name;

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
    with Identifier<I, T> {
  @override
  final I id;

  @override
  final String name;

  const Group(this.id, this.name);
}

abstract base class GroupSet<E extends Group<Comparable, E>> implements Set<E> {
  final LinkedHashSet<E> _gpSet;

  GroupSet(Iterable<E> groups,
      {bool Function(E, E)? equals,
      int Function(E)? hashCode,
      bool Function(dynamic)? isValidKey})
      : _gpSet = LinkedHashSet(
            equals: equals, hashCode: hashCode, isValidKey: isValidKey)
          ..addAll([...groups]..sort());

  @override
  bool add(E value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  void addAll(Iterable<E> elements) {
    // TODO: implement addAll
  }

  @override
  bool any(bool Function(E element) test) {
    // TODO: implement any
    throw UnimplementedError();
  }

  @override
  Set<R> cast<R>() {
    // TODO: implement cast
    throw UnimplementedError();
  }

  @override
  void clear() {
    // TODO: implement clear
  }

  @override
  bool contains(Object? value) {
    // TODO: implement contains
    throw UnimplementedError();
  }

  @override
  bool containsAll(Iterable<Object?> other) {
    // TODO: implement containsAll
    throw UnimplementedError();
  }

  @override
  Set<E> difference(Set<Object?> other) {
    // TODO: implement difference
    throw UnimplementedError();
  }

  @override
  E elementAt(int index) {
    // TODO: implement elementAt
    throw UnimplementedError();
  }

  @override
  bool every(bool Function(E element) test) {
    // TODO: implement every
    throw UnimplementedError();
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) {
    // TODO: implement expand
    throw UnimplementedError();
  }

  @override
  // TODO: implement first
  E get first => throw UnimplementedError();

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) {
    // TODO: implement firstWhere
    throw UnimplementedError();
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    // TODO: implement fold
    throw UnimplementedError();
  }

  @override
  Iterable<E> followedBy(Iterable<E> other) {
    // TODO: implement followedBy
    throw UnimplementedError();
  }

  @override
  void forEach(void Function(E element) action) {
    // TODO: implement forEach
  }

  @override
  Set<E> intersection(Set<Object?> other) {
    // TODO: implement intersection
    throw UnimplementedError();
  }

  @override
  // TODO: implement isEmpty
  bool get isEmpty => throw UnimplementedError();

  @override
  // TODO: implement isNotEmpty
  bool get isNotEmpty => throw UnimplementedError();

  @override
  // TODO: implement iterator
  Iterator<E> get iterator => throw UnimplementedError();

  @override
  String join([String separator = ""]) {
    // TODO: implement join
    throw UnimplementedError();
  }

  @override
  // TODO: implement last
  E get last => throw UnimplementedError();

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) {
    // TODO: implement lastWhere
    throw UnimplementedError();
  }

  @override
  // TODO: implement length
  int get length => throw UnimplementedError();

  @override
  E? lookup(Object? object) {
    // TODO: implement lookup
    throw UnimplementedError();
  }

  @override
  Iterable<T> map<T>(T Function(E e) toElement) {
    // TODO: implement map
    throw UnimplementedError();
  }

  @override
  E reduce(E Function(E value, E element) combine) {
    // TODO: implement reduce
    throw UnimplementedError();
  }

  @override
  bool remove(Object? value) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    // TODO: implement removeAll
  }

  @override
  void removeWhere(bool Function(E element) test) {
    // TODO: implement removeWhere
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    // TODO: implement retainAll
  }

  @override
  void retainWhere(bool Function(E element) test) {
    // TODO: implement retainWhere
  }

  @override
  // TODO: implement single
  E get single => throw UnimplementedError();

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) {
    // TODO: implement singleWhere
    throw UnimplementedError();
  }

  @override
  Iterable<E> skip(int count) {
    // TODO: implement skip
    throw UnimplementedError();
  }

  @override
  Iterable<E> skipWhile(bool Function(E value) test) {
    // TODO: implement skipWhile
    throw UnimplementedError();
  }

  void sort([Comparator<E>? compare]) {
    List<E> sortedGp = [..._gpSet]..sort(compare);

    _gpSet
      ..clear()
      ..addAll(sortedGp);
  }

  @override
  Iterable<E> take(int count) {
    // TODO: implement take
    throw UnimplementedError();
  }

  @override
  Iterable<E> takeWhile(bool Function(E value) test) {
    // TODO: implement takeWhile
    throw UnimplementedError();
  }

  @override
  List<E> toList({bool growable = true}) {
    // TODO: implement toList
    throw UnimplementedError();
  }

  @override
  Set<E> toSet() {
    // TODO: implement toSet
    throw UnimplementedError();
  }

  @override
  Set<E> union(Set<E> other) {
    // TODO: implement union
    throw UnimplementedError();
  }

  @override
  Iterable<E> where(bool Function(E element) test) {
    // TODO: implement where
    throw UnimplementedError();
  }

  @override
  Iterable<T> whereType<T>() {
    // TODO: implement whereType
    throw UnimplementedError();
  }
}

abstract base class User<I extends Comparable, T extends User<I, T>>
    with Identifier<I, T> {
  @override
  final I id;

  @override
  final String name;

  const User(this.id, this.name);
}
