final class Group implements Comparable<Group> {
  final int index;
  final String name;

  const Group(this.index, this.name);

  @override
  int compareTo(Group other) {
    return index.compareTo(other.index);
  }

  @override
  int get hashCode => index * 47 + name.hashCode * 31;

  @override
  String toString() {
    return "$index:$name";
  }

  @override
  bool operator ==(Object other) {
    if (other is Group) {
      return index == other.index && name == other.name;
    }

    return false;
  }
}

extension GroupsSetExtension on Set<Group> {
  String? getNameByIndex(int index) {
    try {
      return singleWhere((g) => g.index == index).name;
    } on StateError {
      return null;
    }
  }

  int? getIndexByName(String name) {
    try {
      return singleWhere((g) => g.name == name).index;
    } on StateError {
      return null;
    }
  }

  bool containsIndex(int index) {
    return where((g) => g.index == index).isNotEmpty;
  }

  bool containsName(String name) {
    return where((g) => g.name == name).isNotEmpty;
  }
}
