import 'package:superuser_plugin_windows/superuser_plugin_windows.dart';

void main(List<String> args) {
  WindowsSuperuser winsu = WindowsSuperuser();

  print("Testing isActivated...");
  try {
    bool elevated = winsu.isActivated;
    print("Is elevated: $elevated");
  } catch (e) {
    print("Error calling isActivated: $e");
  }
  
  print("Testing whoAmI...");
  try {
    var user = winsu.whoAmI;
    print("Current user: $user");
  } catch (e) {
    print("Error calling whoAmI: $e");
  }

  print("Testing groups...");
  try {
    var groups = winsu.groups;
    print("Groups: $groups");
  } catch (e) {
    print("Error calling groups: $e");
  }
}
