## 2.1.0

* Change Dart SDK constraint to `^3.6.0` for applying monorepo support.
* Remove unused `plugin_platform_interface` dependencies.

## 2.0.1

* Fix compare group id overflow issue.

## 2.0.0+1

* Update podspec information.

## 2.0.0

* Implement current user associated groups.

## 2.0.0-m.2

* Expand error code length to two 16-bits, which lower 16-bit denote value of `errno` and upper 16-bit uses for category.

## 2.0.0-m.1

* Change definitions of `isActivated` and `isSuperuser`
    * `isActivated` reuses original `isSuperuser` code
    * `isSuperuser` will also determine a user which allow uses `sudo` command in corresponded group.

## 1.0.0

* Add throw error if native code returns with error.

## 0.1.0

* Define interface's result
    * `isActivated` is alias getter of `isSuperuser` since root is a definition of superuser in UNIX system.
