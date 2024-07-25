## 2.0.0-m.1

* Change definitions of `isActivated` and `isSuperuser`
    * `isActivated` reuses original `isSuperuser` code
    * `isSuperuser` will also determine a user which allow uses `sudo` command in corresponded group.

## 1.0.0

* Add throw error if native code returns with error.

## 0.1.0

* Define interface's result
    * `isActivated` is alias getter of `isSuperuser` since root is a definition of superuser in UNIX system.
