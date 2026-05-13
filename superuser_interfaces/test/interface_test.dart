import 'package:superuser_interfaces/superuser_interfaces.dart';
import 'package:test/test.dart';

final class DecoySuperuserPlatform extends SuperuserPlatform {
  @override
  // TODO: implement groups
  OSStringsSet get groups => throw UnimplementedError();

  @override
  // TODO: implement isActivated
  bool get isActivated => throw UnimplementedError();

  @override
  // TODO: implement isSuperuser
  bool get isSuperuser => throw UnimplementedError();

  @override
  // TODO: implement whoAmI
  OSString get whoAmI => throw UnimplementedError();
}

void main() {
  test("Disallowance of constructing platform during test", () {
    expect(() => DecoySuperuserPlatform(), throwsA(isUnsupportedError));
  });
}
