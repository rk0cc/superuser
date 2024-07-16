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
