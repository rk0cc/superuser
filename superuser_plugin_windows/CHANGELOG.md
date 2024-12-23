## 2.1.0

* Change Dart SDK constraint to `^3.6.0` for applying monorepo support.
* Rewrite C APIs that the functions will flush allocated memory automatically when error occurred.
* Remove unused `plugin_platform_interface` dependencies.

## 2.0.3

* Fix internal uses dynamic memory allocation not released when error occured.

## 2.0.2

* Fix memory not fully released when exception thrown during iterations.

## 2.0.1

* Uses binary search to find admin group.
    * It will throws `ERROR_INVALID_PARAMETER` when this operation failed.

## 2.0.0

* Implement listing joined group for current user.

## 2.0.0-m.2

* Fix incorrect configuration in CMakeLists.txt

## 2.0.0-m.1

* Change condition of `isSuperuser` by finding local user joined Administrators group already.
* Adjust buffer size to 256 wide character.

## 1.0.0

* Add throw error if native code returns with error.
* Improve memory effiency.

## 0.1.0

* Define interface's result
