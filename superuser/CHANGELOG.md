## 4.1.0

* Ditch instance construction guarding into `interface` module
* Fix incorrect year range of license
* Uses group label detection to filter eligable groups in Windows platform
* Apply new line format with correction in `README.md`

## 4.0.0

* Dark hook FFI implementation
    * Minmum Dart SDK becomes `^3.10.0`
    * Cease Flutter dependencies
* New `SuperuserProcessError` structure with enhanced readability.
* New string wrapper: `OSString`
    * Compare string depending on applied staregy in the platform.
* New collection: `OSStringSet`

## 3.0.0+1

* Fix Flutter and Dart SDK version unaligned problem.
* Fix repository link unreachable problem as the default branch renamed.

## 3.0.0

* Change Dart SDK constraint to `^3.8.0`
* Windows
    * Adapt UTF-16 for parsing string in Windows plugin rather than converting to UTF-8.
    * Cease case insensitivity group set implementation.
* Unix
    * Add few groups name for detecting superuser groups in other Unix platform.
    * Fix name resolve error when fetching groups
* `superuser_demo` rejoined as workspace in repository.

## 2.1.1

* Case sensitivity in group set is depends on Operating System now (only Windows is case insensitive).

## 2.1.0

* Change Dart SDK to `^3.6.0` for monorepo support.
* `Superuser.groups` returns `Set` rather than `Iterable`.

## 2.0.0

* Add user's joined group in local machine scope.

## 2.0.0-m.1

* `isSuperuser` can returns true without superuser permission activated.
    * Windows: Uses `NetUserGetLocalGroups` to find current user is a member of `Administrators`.
    * UNIX: Determine user joined default `sudo` command enabled groups (`admin` in macOS, `sudo` in Linux).
* Expand UNIX's error code to unsigned 32-bits length with two 16-bits segmentes:
    * Lower 16-bits reuses origin error numbers from libraries.
    * Upper 16-bits denotes error categories that causing error thrown.

## 1.0.2

* Add assertion to prevent using mock interface in release mode.

## 1.0.1

* Resolve lower score due to violation of formatting
* Provide `SuperuserProcessError` for catching error when fetching from plugin.

## 1.0.0

* Add error handling
* Integrate instance managing feature into `SuperuserInstance`
* Improve effience of memory allocation in Windows platform.
* Remove `MockSuperuser` restriction and mark as constant.

## 0.1.1

* Exclude `SuperuserInterface` in `superuser` library.
* Append `ffi` in pubspec topic.

## 0.1.0

* New feature
    * Detect user has superuser role
    * Determine a Flutter program executed under superuser role
    * `whoami` command: Retrive current username who responsible of executing this program.
