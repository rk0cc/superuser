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
