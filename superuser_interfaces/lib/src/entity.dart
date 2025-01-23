import 'package:meta/meta.dart';

abstract class Identifier<T extends Identifier<T>> extends Iterable<int>
    implements Comparable<T> {
  const Identifier();

  @mustBeOverridden
  @override
  int get length {
    throw UnimplementedError("Identifier length does not implemented.");
  }

  @override
  int get hashCode {
    int hash = 7;

    for (int seq in this) {
      hash += 31 * hash + seq;
    }

    return hash;
  }

  @override
  bool operator ==(Object other) {
    if (other is! T) {
      return false;
    } else if (length == other.length) {
      return false;
    }

    for (int i = 0; i < length; i++) {
      if (elementAt(i) != other.elementAt(i)) {
        return false;
      }
    }

    return true;
  }
}

sealed class Entity<I extends Identifier<I>> {
  final I _id;
  final String _name;

  const Entity(I id, String name) : _id = id, _name = name;

  bool equalsId(I id) =>  _id == id;

  bool equalsName(String name);
}

mixin UncasedNameEntity<I extends Identifier<I>> on Entity<I> {
  @override
  bool equalsName(String name) => _name.toUpperCase() == name.toUpperCase();
}

mixin CasedNameEntity<I extends Identifier<I>> on Entity<I> {
  @override
  bool equalsName(String name) => _name == name;
}

@internal
extension EntityGetter<I extends Identifier<I>> on Entity<I> {
  I get id => _id;

  String get name => _name;
}

abstract base class Group<I extends Identifier<I>> extends Entity<I> {
  const Group(super.id, super.name);
}

abstract base class User<I extends Identifier<I>> extends Entity<I> {
  const User(super.id, super.name);
}
