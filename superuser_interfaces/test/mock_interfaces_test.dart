import 'package:superuser_interfaces/superuser_interfaces.dart' show MockSuperuser;
import 'package:test/test.dart';

void main() {
  test("Mock interfaces construction test", () {
    expect(() => MockSuperuser(whoAmI: "Sample 1"), returnsNormally);
    expect(() => MockSuperuser(isSuperuser: true), returnsNormally);
    expect(() => MockSuperuser(isSuperuser: true, isActivated: true), returnsNormally);
    expect(() => MockSuperuser(isActivated: true), throwsA(isA<AssertionError>()));
  });
}